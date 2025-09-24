#!/usr/bin/env node
/*
 Conditionally seed the database when SEED_ON_START=true.
 Always exit 0 to avoid failing deployments when seeding is optional.
*/
const { spawnSync } = require('node:child_process');

const shouldSeed = String(process.env.SEED_ON_START || '').toLowerCase() === 'true';

if (!shouldSeed) {
  console.log('Skipping DB seed (SEED_ON_START not true).');
  process.exit(0);
}

console.log('Running DB seed (SEED_ON_START=true)...');
const result = spawnSync('node', [
  './node_modules/prisma/build/index.js',
  'db',
  'seed',
  '--schema=./prisma/schema-production.prisma'
], { stdio: 'inherit', shell: false });

process.exit(result.status === 0 ? 0 : 0);

