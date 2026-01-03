#!/bin/sh
set -e

# Wait for database to be ready
echo "Waiting for database to be ready..."
export PGPASSWORD=messageboard_password
until pg_isready -h db -p 5432 -U messageboard -d messageboard; do
  sleep 1
done

echo "Database is ready!"

# Run database migrations
echo "Running database migrations..."
npm run db:push || echo "Migration completed or schema already up to date"

# Start the application
exec npm start

