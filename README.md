Tabula API
==========

TODO Write stuff

# Run migrations

```
sequel -m db/migrations jdbc:sqlite://`pwd`/db/tabula-api.db
```

# Run dev server

```
TABULA_API_DATABASE_URL="jdbc:sqlite://`pwd`/db/tabula-api.db" rackup
```
