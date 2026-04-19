# ── Stage 1: Build ────────────────────────────────────────
FROM node:20-alpine AS builder

WORKDIR /app

# Copy file quản lý thư viện và cài đặt (bao gồm devDependencies để có TypeScript)
COPY package*.json ./
RUN npm install

# Copy toàn bộ source code và tiến hành build TS -> JS
COPY . .
RUN npm run build

# ── Stage 2: Runtime (Production) ─────────────────────────
FROM node:20-alpine

WORKDIR /app

# Để root copy file và cài đặt thư viện
COPY package*.json ./
RUN npm install --omit=dev

# Copy thư mục dist đã được build từ Stage 1 sang
COPY --from=builder --chown=node:node /app/dist ./dist

# Sau khi nhà cửa đã xây xong, mới giao lại quyền cho user 'node' để chạy app
USER node

# Mở port
EXPOSE 3000

# Chạy app
CMD ["npm", "run", "serve"]