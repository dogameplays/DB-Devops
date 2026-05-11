FROM mysql:8.0
# Los scripts en esta carpeta se ejecutan automáticamente al iniciar
COPY ./schema.sql /docker-entrypoint-initdb.d/1-schema.sql
COPY ./seed.sql /docker-entrypoint-initdb.d/2-seed.sql
