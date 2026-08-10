import { readFileSync } from 'node:fs';
import { join } from 'node:path';

import { describe, expect, it } from 'vitest';

const source = readFileSync(join(import.meta.dirname, '..', 'prisma', 'schema.prisma'), 'utf8');

/**
 * The schema with `//` comments stripped. Assertions run against this rather than the raw file so
 * that prose describing a field — including the header comment explaining why the Invite /
 * SerialKey relation arrays are absent — is never mistaken for a declaration of it.
 */
const declarations = source.replace(/\/\/.*$/gm, '');

/** Returns the member list of an `enum <name> { … }` block, in declaration order. */
function enumMembers(name: string): string[] {
  const block = new RegExp(`enum ${name} \\{([^}]*)\\}`).exec(declarations);
  if (!block?.[1]) throw new Error(`enum ${name} is not declared in schema.prisma`);
  return block[1].trim().split(/\s+/);
}

describe('schema.prisma enums', () => {
  it.each([
    ['UserStatus', ['waiting', 'invited', 'active', 'disabled']],
    ['IdentitySource', ['email', 'github']],
    ['UserRole', ['user', 'admin']],
    ['SerialKeyStatus', ['active', 'revoked']],
  ])('%s declares exactly its design-delta §2.1 members', (name, members) => {
    expect(enumMembers(name)).toEqual(members);
  });
});

describe('schema.prisma User model', () => {
  it('carries the composite index the position query and admin tabs need', () => {
    expect(declarations).toContain('@@index([status, createdAt])');
  });

  it('does not declare relation fields whose models do not exist yet', () => {
    // Invite and SerialKey are plan.md tasks 16 and 17. Declaring the relation arrays before the
    // models exist makes `prisma validate` fail (P1012), which is task 3's own done-when.
    expect(declarations).not.toContain('Invite[]');
    expect(declarations).not.toContain('SerialKey[]');
  });
});
