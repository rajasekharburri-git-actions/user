# ---------- BUILD STAGE ----------
FROM node:20.19.5-alpine3.21 AS build

WORKDIR /opt/server

# Copy dependency files first for better layer caching
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application source
COPY *.js ./

# ---------- RUNTIME STAGE ----------
FROM node:20.19.5-alpine3.21

WORKDIR /opt/server

# Create non-root user
RUN addgroup -S roboshop && \
    adduser -S roboshop -G roboshop

# Copy app from build stage
COPY --from=build --chown=roboshop:roboshop /opt/server /opt/server

# Environment variables
ENV MONGO=true \
    REDIS_URL=redis://redis:6379 \
    MONGO_URL=mongodb://mongodb:27017/users

# Expose app port
EXPOSE 8080

# Metadata
LABEL com.project="roboshop" \
      component="user" \
      created_by="sivakumar"

# Run as non-root user
USER roboshop

# Start application
CMD ["node", "server.js"]