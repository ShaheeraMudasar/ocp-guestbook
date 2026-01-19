#!/bin/bash

if [ -f ./backend/.env ]; then
  export $(grep -v '^#' ./backend/.env | xargs)
fi

# 1. Create the network
podman network inspect guestbook-net >/dev/null 2>&1 || podman network create guestbook-net
echo "created network guestbook-net"

# 2. Start Postgres (Using the variable from .env)
echo "Starting Postgres..."

podman run -d --name postgres \
  --network guestbook-net \
  -v pgdata:/var/lib/pgsql/data:Z \
  -e POSTGRESQL_USER=guestbook \
  -e POSTGRESQL_PASSWORD=$DB_PASSWORD \
  -e POSTGRESQL_DATABASE=guestbook \
  -p 5432:5432 \
  quay.io/fedora/postgresql-16:latest

# 3. Start Redis (Using the variable from .env)
echo "Starting Redis..."

podman run -d --name redis \
  --network guestbook-net \
  -v redisdata:/data:Z \
  -e REDIS_PASSWORD=$REDIS_PASSWORD \
  -p 6379:6379 \
  quay.io/kurs/redis:latest

# 4. Start Backend with .env Volume Mount
echo "Starting Backend..."
podman run -d --name backend \
  --network guestbook-net \
  --env-file ./backend/.env \
  -p 8080:8080 \
  guestbook-backend:latest

# 5. Start Frontend (Mapping Laptop 8081 to Container 8080)
echo "Starting Frontend..."
podman run -d --name frontend \
  --network guestbook-net \
  -p 8081:8080 \
  guestbook-frontend:latest

echo "---------------------------------------"
echo "Guestbook is running!"
echo "Frontend: http://localhost:8081"
echo "Backend Health: http://localhost:8080/health"
echo "---------------------------------------"