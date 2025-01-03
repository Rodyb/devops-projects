FROM mcr.microsoft.com/playwright:v1.49.0-jammy

ENV CI=1
USER root

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY package.json package-lock.json ./

RUN npm ci

RUN npx playwright install --with-deps

COPY . .