FROM node:18

WORKDIR /tests

COPY package*.json ./

RUN npm ci

COPY . .

CMD ["npx", "jest"]
