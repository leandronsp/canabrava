FROM ubuntu AS base
RUN apt update && apt install -y netcat socat jq sqlite3 
WORKDIR /app
