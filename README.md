# Code for The Little SQL Book

Hiya! This is the code for the free ebook, *The Little SQL Book* which you can [find right here](https://bigmachine.io/little-sql). It's about 50 pages long, give or take, and digs into creating tables and querying **fantasy footbal data** from 2019, the goal of which is to create a fantasy cheatsheet.

## Getting Up and Running

The easiest thing to do is to run everything in Docker. There's a `docker-compose.yml` file in the `docker` directory that has everything you need. It will load up PostgreSQL, PGWeb (a kickass web GUI for Postgres) and the initial set of data.

```
docker-compose up
```

If you have any trouble, just leave an issue here.

Have fun!