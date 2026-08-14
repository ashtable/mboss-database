# mboss-database

mboss - Design Durable Apps with DBOS - Database migrations and shared data models

## Local development

The database comes from the superproject's compose stack, not from an ad-hoc container:

```bash
cd ..                        # the mboss superproject root
docker compose up -d postgres
```

`DATABASE_URL` lives in `.env` (gitignored); copy `.env.example` to `.env` to get the host-side
form. Prisma 7 does not auto-load `.env` — `prisma.config.ts` does `import "dotenv/config"`, which
is why `dotenv` is a devDependency.

```bash
npm run migrate:dev          # create + apply a migration
npm run lint                 # tsc, eslint, prettier, and `prisma validate`
npm test
```

### Two things that will bite later

**Shadow database.** `prisma migrate dev` creates and drops a temporary shadow database on every
run, so the connecting role needs `CREATEDB`. The compose superuser has it, so nothing is
configured here. Pointing this repo at a managed Postgres or a non-superuser role means granting
`CREATEDB` or setting an explicit `shadowDatabaseUrl`.

**Constructing a client needs a driver adapter.** On Prisma 7 a bare `new PrismaClient()` throws
regardless of generator — it wants `new PrismaClient({ adapter: new PrismaPg({ connectionString }) })`
with `@prisma/adapter-pg` and `pg` installed. Nothing in this repo constructs a client, so those
dependencies are deliberately absent; whoever first instantiates one (the API) adds them there.
