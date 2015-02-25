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

sqlite3 ../../.tabula/tabula_api.db
bundle exec sequel -m db/migrations/ jdbc:sqlite:../../.tabula/tabula_api.db

### Run dev server

```
rackup
```
