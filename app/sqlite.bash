#!/bin/bash

DB_FILE="/app/app/db/database.db"
INIT_SCRIPT="/app/app/db/init.sql"

# Verifica se o arquivo do banco de dados já existe
if [ ! -f "$DB_FILE" ]; then
    sqlite3 "$DB_FILE" < "$INIT_SCRIPT"
fi
