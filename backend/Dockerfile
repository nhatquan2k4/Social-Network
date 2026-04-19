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

# Bảo mật: Chạy app bằng user 'node' có sẵn của image, không dùng quyền root
USER node

# Copy file quản lý thư viện và CHỈ cài đặt dependencies cho production
COPY package*.json ./
RUN npm install --omit=dev

# Copy thư mục dist đã được build từ Stage 1 sang
COPY --from=builder --chown=node:node /app/dist ./dist

# Mở port (Giả định là 3000, chúng ta sẽ điều chỉnh nếu app của bạn dùng port khác)
EXPOSE 3000

# Chạy app bằng script đã định nghĩa trong package.json
CMD ["npm", "run", "serve"]