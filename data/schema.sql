-- Bahrmetr database schema (plaintext reference copy)
-- Source: B4A/Files/behrdat.db (SQLCipher-encrypted in the app)
-- See ../DATA.md for full description and statistics.

PRAGMA foreign_keys=OFF;

BEGIN TRANSACTION;
CREATE TABLE "bahrs" (
	"BEHR"	TEXT,
	"QALIB"	TEXT,
	"KOD"	TEXT,
	"HECA"	INTEGER
, "trqalib" text);
CREATE TABLE qelibs (behr TEXT, qelib TEXT, digqel TEXT, hga INTEGER, trqelib TEXT, "enqelib" text);
COMMIT;
