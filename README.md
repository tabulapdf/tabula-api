Tabula API
==========

**Important**: `tabula-api` is not yet functional.

## Methods

```
GET /documents
 Returns all the documents stored in Tabula
  parameters:
POST /documents
 Upload a PDF
  parameters:
   * file:  (required)
GET /documents/:uuid
 An uploaded document
  parameters:
   * uuid:
GET /documents/:uuid/document
 Download the original PDF
  parameters:
   * uuid:
DELETE /documents/:uuid
 Delete an uploaded document
  parameters:
   * uuid:
POST /documents/:uuid/tables
 Extract tables
  parameters:
   * uuid:
   * coords:  (required)
   * extraction_method:
DELETE /documents/:uuid/pages/:number
 Delete a page from a document
  parameters:
   * uuid:
   * number:  (required)

```

## Installation

### Run migrations

```
sequel -m db/migrations jdbc:sqlite://`pwd`/db/tabula-api.db
```

### Run dev server

```
TABULA_API_DATABASE_URL="jdbc:sqlite://`pwd`/db/tabula-api.db" rackup
```
