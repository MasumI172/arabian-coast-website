# Stage 1 – Build
FROM node:20-alpine AS builder

WORKDIR /app

# Copy dependencies and install them (including devDeps for build)
COPY package*.json ./
RUN npm install

# Copy full source code
COPY . .

# Build the frontend and backend
RUN npm run build


# Stage 2 – Run
FROM node:20-alpine

WORKDIR /app

# Copy only production deps
COPY package*.json ./
RUN npm ci --omit=dev

# Copy built app from builder
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/public ./public  # if frontend output is needed
COPY --from=builder /app/.env ./.env      # optional

# Set environment (optional, but good practice)
ENV NODE_ENV=production

EXPOSE 5000

CMD ["node", "dist/index.js"]
