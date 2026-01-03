FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm ci

COPY . .

RUN npm run build

# Production stage
FROM node:20-alpine AS production

RUN apk add --no-cache postgresql-client

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm ci --only=production && \
    npm install drizzle-kit --save-dev --no-save

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/shared ./shared
COPY --from=builder /app/drizzle.config.ts ./drizzle.config.ts

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 5000

ENV NODE_ENV=production
ENV PORT=5000

ENTRYPOINT ["docker-entrypoint.sh"]

