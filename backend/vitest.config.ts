import path from 'node:path';
import { readD1Migrations } from '@cloudflare/vitest-pool-workers/config'
import { defineWorkersConfig } from '@cloudflare/vitest-pool-workers/config'

export default defineWorkersConfig(async () => {
  const migrationsPath = path.join(__dirname, 'drizzle/migrations')
  const migrations = await readD1Migrations(migrationsPath)
  return {
    test: {
    setupFiles: ['./test/apply_migration'],
    globals: true,
    poolOptions: {
      workers: {
        main: "./src/index.ts",
        miniflare: {
          compatibilityDate: '2024-04-01',
          d1Databases: ["DB"],
          bindings: { TEST_MIGRATIONS: migrations }
        },
      },
    },
  },
}})
