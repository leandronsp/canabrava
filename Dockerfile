FROM ubuntu AS base
RUN apt update && apt install -y netcat postgresql-client socat
WORKDIR /app
