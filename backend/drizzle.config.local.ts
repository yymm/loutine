import { defineConfig } from 'drizzle-kit';
import { readdirSync } from 'node:fs';

const local_d1_dir = '.wrangler/state/v3/d1/miniflare-D1DatabaseObject'
const local_d1_filename = readdirSync(local_d1_dir).find((filename) => {
  return filename.endsWith('.sqlite');
});

export default defineConfig({
  schema: './src/schema.ts',
  out: './drizzle/migrations',
  dialect: 'sqlite',
  dbCredentials: {
    url: `${local_d1_dir}/${local_d1_filename}`,
  },
})
