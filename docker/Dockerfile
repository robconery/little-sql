FROM postgres:14-alpine
COPY ff.sql /docker-entrypoint-initdb.d/seed.sql
ENV POSTGRES_USER=docker POSTGRES_PASSWORD=docker POSTGRES_DB=ff
EXPOSE 5432