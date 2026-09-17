# =========================
# Stage 1 — Build
# =========================
FROM node:22-slim AS build

WORKDIR /app

COPY package*.json ./
COPY tsconfig.json ./

RUN npm ci

COPY src ./src

RUN npm run build


# =========================
# Stage 2 — Runtime
# =========================
FROM node:22-slim

WORKDIR /app

COPY package*.json ./

# Instala SOMENTE dependências de produção, e remove o npm do runtime, pq ele tinha vulnerabilidades
RUN npm ci --omit=dev \
    && npm cache clean --force \
    && rm -rf /usr/local/lib/node_modules/npm

COPY --from=build /app/dist ./dist

EXPOSE 3000

CMD ["node", "dist/index.js"]
