# Service-b Dockerfile
FROM node:20-slim AS builder

WORKDIR /app

COPY package.json ./

RUN npm install --only=production

FROM node:20-slim

USER node

WORKDIR /app

COPY --from=builder /app/node_modules ./node_modules
COPY . .

ENV SERVICE_A_URL=http://service-a:5000

CMD ["node", "worker.js"]