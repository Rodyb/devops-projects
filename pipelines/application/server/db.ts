import * as schema from "@shared/schema";
// pg is a CommonJS module, need to use default import
import pg from 'pg';
import { drizzle as drizzlePG } from 'drizzle-orm/node-postgres';
import { Pool as NeonPool, neonConfig } from '@neondatabase/serverless';
import { drizzle as drizzleNeon } from 'drizzle-orm/neon-serverless';
import ws from "ws";

if (!process.env.DATABASE_URL) {
  throw new Error(
    "DATABASE_URL must be set. Did you forget to provision a database?",
  );
}

// Support both Neon serverless and standard PostgreSQL
// Use standard PostgreSQL if USE_STANDARD_PG is set, or if DATABASE_URL doesn't contain 'neon'
const useStandardPG = process.env.USE_STANDARD_PG === 'true' || 
  !process.env.DATABASE_URL.includes('neon.tech');

let pool: any;
let db: any;

if (useStandardPG) {
  // Standard PostgreSQL using node-postgres
  pool = new pg.Pool({ connectionString: process.env.DATABASE_URL });
  db = drizzlePG({ client: pool, schema });
} else {
  // Neon serverless
  neonConfig.webSocketConstructor = ws;
  pool = new NeonPool({ connectionString: process.env.DATABASE_URL });
  db = drizzleNeon({ client: pool, schema });
}

export { pool, db };
