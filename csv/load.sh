# This is our "extractor", pulling data from the CSVs and loading it into SQLite
# I'm doing this because SQLite is pretty good at creating SQL statements
# Which I need so I can load into Postgres
# You can run this file using source ./load.sh

function csv_to_sqlite() {
  local stub="$1"
  (echo .separator ,; echo .import $1.csv $1) | sqlite3 ff.db
}

rm -rf ff.db


csv_to_sqlite quarterbacks;
csv_to_sqlite running_backs;
csv_to_sqlite wide_receivers;
csv_to_sqlite tight_ends;
csv_to_sqlite defense;

echo "drop schema if exists csvs cascade; \ncreate schema csvs; \nset search_path=csvs;\n" > import.sql

# this is a useful command for scrubbing SQLite data
# I got it from here: https://stackoverflow.com/a/25924065
#sqlite3 mjsqlite.db .dump | sed -e 's/INTEGER PRIMARY KEY AUTOINCREMENT/SERIAL PRIMARY KEY/g;s/PRAGMA foreign_keys=OFF;//;s/unsigned big int/BIGINT/g;s/UNSIGNED BIG INT/BIGINT/g;s/BIG INT/BIGINT/g;s/UNSIGNED INT(10)/BIGINT/g;s/BOOLEAN/SMALLINT/g;s/boolean/SMALLINT/g;s/UNSIGNED BIG INT/INTEGER/g;s/INT(3)/INT2/g;s/DATETIME/TIMESTAMP/g'
# all I need is the PRAGMA key thing scrubbed out, that's what "sed" does - runs an inline editing process
sqlite3 ff.db ".dump" | sed -e 's/PRAGMA foreign_keys=OFF;//' >> import.sql
psql ff "drop schema if exists csvs cascade; create schema csvs;"
psql ff < import.sql;

#copy to the root
cp import.sql ./ff.sql
#move this to our docker bits
mv import.sql ../docker/ff.sql


#move the SQLite bits to the root as well
rm -rf ../ff.db
mv ff.db ../ff.db
