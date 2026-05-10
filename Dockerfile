FROM node:20.19.5-alpine3.21 AS build

WORKDIR /opt/server

# Update Alpine packages
RUN apk update && apk upgrade

COPY package*.json ./
RUN npm ci --only=production

COPY *.js ./

FROM node:20.19.5-alpine3.21

WORKDIR /opt/server

# Update Alpine packages
RUN apk update && apk upgrade

RUN addgroup -S roboshop && \
    adduser -S roboshop -G roboshop

COPY --from=build --chown=roboshop:roboshop /opt/server /opt/server

ENV MONGO=true \
    REDIS_URL=redis://redis:6379 \
    MONGO_URL=mongodb://mongodb:27017/users

EXPOSE 8080

USER roboshop

CMD ["node", "server.js"]