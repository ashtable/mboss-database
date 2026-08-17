import { readFileSync } from 'node:fs';
import { join } from 'node:path';

import { describe, expect, it } from 'vitest';

const source = readFileSync(
  join(import.meta.dirname, '..', 'prisma', 'schema.prisma'),
  'utf8',
);

/**
 * `source` with `//` comments stripped.
 * Assertions run against this, not the raw
 * text, so prose describing a field is never
 * mistaken for the field's declaration.
 */
const declarations = source.replace(/\/\/.*$/gm, '');

/**
 * The member list of an `enum <name> { … }`
 * block, in declaration order.
 */
function enumMembers(name: string): string[] {
  const block = new RegExp(`enum ${name} \\{([^}]*)\\}`).exec(declarations);
  if (!block?.[1])
    throw new Error(`enum ${name} is not declared in schema.prisma`);
  return block[1].trim().split(/\s+/);
}

describe('schema.prisma enums', () => {
  it.each([
    ['SubscriberStatus', ['subscribed', 'paused', 'unsubscribed', 'bounced']],
    ['SubscriberSource', ['email', 'admin']],
    ['BroadcastStatus', ['draft', 'sending', 'sent', 'failed']],
    ['DeliveryStatus', ['pending', 'sent', 'failed', 'skipped']],
  ])('%s declares exactly its members, in order', (name, members) => {
    expect(enumMembers(name)).toEqual(members);
  });
});

describe('schema.prisma models', () => {
  it('carries the composite index the admin status tabs page on', () => {
    expect(declarations).toContain('@@index([status, createdAt])');
  });

  it('carries the createdAt index the broadcast list orders on', () => {
    expect(declarations).toContain('@@index([createdAt])');
  });

  it('carries the one-row-per-recipient uniqueness the send step flips on', () => {
    expect(declarations).toContain('@@unique([broadcastId, subscriberId])');
  });

  it.each(['Subscriber', 'Broadcast', 'BroadcastDelivery'])(
    'declares model %s',
    (model) => {
      expect(declarations).toContain(`model ${model} {`);
    },
  );
});

describe('the pivot removed the invite-gate and licensing vocabulary', () => {
  // These strings must not survive anywhere in
  // the file — including inside comments, which
  // is why this asserts against raw source, not
  // the comment-stripped declarations. A dead
  // symbol left in prose still tells the next
  // person it matters.
  it.each(['SerialKey', 'Invite', 'UserStatus', 'UserRole', 'IdentitySource'])(
    'no trace of %s',
    (dead) => {
      expect(source).not.toContain(dead);
    },
  );
});
