# Multi-stage Docker build for Ramparts Gemini CLI Integration

# Stage 1: Build Ramparts (Rust)
FROM rust:1.75-slim as ramparts-builder

# Install system dependencies
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /build

# Copy Ramparts source code (from parent directory)
COPY ../Cargo.toml ../Cargo.lock ./
COPY ../src ./src/
COPY ../rules ./rules/
COPY ../build.rs ./

# Build Ramparts
RUN cargo build --release

# Stage 2: Build MCP Server (Node.js)
FROM node:18-alpine as mcp-builder

# Set working directory
WORKDIR /build

# Copy MCP server source
COPY mcp-server/package.json mcp-server/package-lock.json ./
RUN npm ci --only=production

# Copy source and build
COPY mcp-server/src ./src/
COPY mcp-server/tsconfig.json ./
RUN npm run build

# Stage 3: Final runtime image
FROM node:18-alpine

# Install system dependencies
RUN apk add --no-cache \
    bash \
    curl \
    git \
    && addgroup -g 1001 -S ramparts \
    && adduser -S ramparts -u 1001

# Set working directory
WORKDIR /app

# Copy built artifacts
COPY --from=ramparts-builder /build/target/release/ramparts /usr/local/bin/
COPY --from=mcp-builder /build/dist ./mcp-server/dist/
COPY --from=mcp-builder /build/node_modules ./mcp-server/node_modules/
COPY --from=mcp-builder /build/package.json ./mcp-server/

# Copy integration files
COPY slash-commands ./slash-commands/
COPY scripts ./scripts/
COPY docs ./docs/
COPY examples ./examples/
COPY package.json ./

# Make scripts executable
RUN chmod +x scripts/*.sh

# Create directories for Gemini CLI
RUN mkdir -p /home/ramparts/.gemini/commands \
    && chown -R ramparts:ramparts /home/ramparts

# Switch to non-root user
USER ramparts

# Set environment variables
ENV NODE_ENV=production
ENV RAMPARTS_PORT=3001
ENV RAMPARTS_TIMEOUT=180
ENV PATH="/app/scripts:${PATH}"

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:${RAMPARTS_PORT}/health || exit 1

# Expose MCP server port
EXPOSE 3001

# Default command
CMD ["node", "mcp-server/dist/index.js"]

# Labels
LABEL org.opencontainers.image.title="Ramparts Gemini CLI Integration"
LABEL org.opencontainers.image.description="Security scanning integration for Gemini CLI with TOML commands and MCP server"
LABEL org.opencontainers.image.vendor="Javelin"
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.source="https://github.com/getjavelin/ramparts"
LABEL org.opencontainers.image.documentation="https://github.com/getjavelin/ramparts/tree/feature/gemini-cli-integration/gemini-cli-integration"
LABEL org.opencontainers.image.licenses="Apache-2.0"