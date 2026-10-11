# The Bahrmetr database

`behrdat.db` is the app's only data source. It contains every meter pattern the
app knows about, pre-encoded for matching.

---

## Files

| Path | What it is |
|---|---|
| `Project/Bahrmetr/B4A/Files/behrdat.db` | **The shipped asset.** SQLCipher-encrypted, 663,552 bytes. Copied to internal storage on first run. |
| `data/behrdat-plaintext.db` | **Readable copy**, committed so the data can be inspected and extended. 593,920 bytes. |
| `data/schema.sql` | Schema only, no data. |
| `data/decrypt_db.py` | Regenerates the plaintext copy from the encrypted one. |

---

## Regenerating the plaintext copy

```bash
python3 -m venv .venv
./.venv/bin/pip install sqlcipher3-binary
./.venv/bin/python data/decrypt_db.py --force
```

Expected output:

```
  bahrs        3467 rows
  qelibs         94 rows

  size:   593920 bytes
  sha256: 50dcf03965b8e44b83bfa6ac826eba23215e9f9e5e2ac22904f9aabc4cf7bd85
```

If you have the `sqlcipher` CLI instead, the script falls back to it
automatically.

The password is read from `Project/Bahrmetr/B4A/ConnectDB.bas`, so there is one
source of truth.

---

## ⚠️ The encryption provides no confidentiality

The database is encrypted with SQLCipher, but **the password is hard-coded in
the source**:

```basic
' Project/Bahrmetr/B4A/ConnectDB.bas:14
Private psw As String = "masmililer123!5"
```

The encrypted file ships inside the APK and the password ships in the source
that built it. Anyone can unzip the app, read the password, and decrypt the
data. SQLCipher here is obfuscation, not security.

It does add ~11 MB of native `.so` libraries to the APK across five ABIs. If you
are forking this and do not need to preserve the encrypted asset format,
switching to a plain SQLite database is a straightforward win.

---

## Cipher parameters

Non-obvious, and needed if you rewrite the decryptor. The bundled
`libsqlcipher.so` reports version **4.0.0** but still exports SQLCipher 3.x
cipher names (`aes-256-cbc-hmac-sha1`), which is misleading:

| Setting | Value |
|---|---|
| Key derivation | `PBKDF2_HMAC_SHA512` |
| Iterations | `256000` |
| Page size | `4096` |
| HMAC | `HMAC_SHA512` |

Trying SHA-1 defaults fails with `hmac check failed for pgno=1`.

---

## Schema

```sql
CREATE TABLE "bahrs" (
    "BEHR"    TEXT,     -- internal meter key, e.g. 'hazac'
    "QALIB"   TEXT,     -- pattern name, Azerbaijani
    "KOD"     TEXT,     -- encoded binary pattern, e.g. '0101010100100010...'
    "HECA"    INTEGER,  -- syllable count, used to narrow the search
    "trqalib" text      -- pattern name, Turkish
);

CREATE TABLE qelibs (
    behr     TEXT,      -- internal meter key
    qelib    TEXT,      -- canonical pattern name, Azerbaijani
    digqel   TEXT,      -- canonical encoded pattern
    hga      INTEGER,   -- syllable count
    trqelib  TEXT,      -- canonical pattern name, Turkish
    "enqelib" text      -- canonical pattern name, English — EMPTY
);
```

Note the inconsistent casing between the two tables (`bahrs` is all-caps,
`qelibs` is lowercase). The queries rely on SQLite's case-insensitivity for
column names, so this works — but it is a trap when writing new SQL.

`PRAGMA integrity_check` returns `ok`.

---

## Contents

### `bahrs` — 3,467 rows

Every encoded verse pattern the app has seen, across 9 meters:

| Meter key | Rows | Displayed as |
|---|---:|---|
| `hazac` | 1,255 | Hazaj / Həzəc |
| `ramal` | 1,044 | Ramal / Rəməl |
| `muzare` | 384 | Mudari / Müzare |
| `khafif` | 320 | Khafif / Xəfif |
| `racaz` | 224 | Rajaz / Rəcəz |
| `sari` | 112 | Sari / Səri |
| `muctas` | 82 | Mujtathth / Müctəs |
| `munsarih` | 34 | Munsarih / Münsərih |
| `mutedarik` | 12 | Mutadarik / Mütədarik |

`HECA` (syllable count) ranges **5–20**. `trqalib` is fully populated (3,467 /
3,467).

### `qelibs` — 94 rows

Canonical patterns across **12** meters — this is where the app's "About" text
claim of *12 meters* comes from:

| Meter key | Patterns | | Meter key | Patterns |
|---|---:|---|---|---:|
| `hazac` | 22 | | `khafif` | 6 |
| `ramal` | 21 | | `muzare` | 5 |
| `mutedarik` | 9 | | `muctas` | 5 |
| `racaz` | 8 | | `mutaqarib` | 4 |
| `munsarih` | 8 | | `sari` | 3 |
| | | | `kamil` | 2 |
| | | | `muqtazab` | 1 |

`hga` ranges **5–20**.

---

## Data quality notes

### `enqelib` is completely empty

**0 of 94 rows** have an English pattern name. The app's "About" screen
advertises full English support, but the pattern names are never populated.

Compounding this, `B4XMainPage.bas` reads the **Turkish** column for both
Turkish *and* English (`GetString("trqelib")`, lines 390 and 411), so English
users currently see Turkish pattern names.

This one *can* be fixed without touching application logic — see below.

### `bahrs` covers 9 meters, `qelibs` covers 12

`kamil`, `muqtazab` and `mutaqarib` exist only in `qelibs`. The fallback path
(`checkSimilarity`, which queries `bahrs`) can therefore never return them. The
"About" claim of 12 meters is accurate for the primary path only.

### No indexes

Neither `bahrs.HECA` nor `qelibs.hga` is indexed, and those are the columns
every query filters on:

```sql
SELECT * FROM qelibs WHERE hga = ?
SELECT * FROM bahrs  WHERE HECA = ?
```

Each search is a full table scan over 3,467 rows. Irrelevant at this size, but
it is the first thing to add if the dataset grows.

### Uneven coverage

`hazac` has 1,255 patterns and `mutedarik` has 12. A heavily-used meter will
match far more readily than a rare one, which biases results toward the common
meters regardless of the input.

---

## Extending the data

### Adding an English pattern name

Pure data change — no code edit required:

```sql
UPDATE qelibs SET enqelib = 'MefA''Ilun mefA''Ilun' WHERE digqel = '1000100010001000';
```

But note `B4XMainPage.bas` will not *read* that column until the query is
changed from `trqelib` to `enqelib` for English mode — see
[known issue #6](KNOWN_ISSUES.md#6-english-users-get-blank-pattern-names).

### Adding a canonical pattern

```sql
INSERT INTO qelibs (behr, qelib, digqel, hga, trqelib, enqelib)
VALUES ('hazac', 'Fə''Ulün fə''Ulün', '10001000100', 11, 'Fe''Ulün fe''Ulün', NULL);
```

- `digqel` is built by the same encoding as `kodla` in `B4XMainPage.bas`: `1`
  for each vowel (`a e i o u ə ö ü ı`), `0` for everything else, after
  `Utils.formatMisra` has stripped punctuation and spaces.
- `hga` must be the count of `1`s.
- Beware the [encoding bug at line 149](KNOWN_ISSUES.md#3-encoded-strings-are-corrupted-for-verses-ending-in-a-vowel)
  when hand-encoding verses that end in a vowel.

### Adding encoded verse patterns

```sql
INSERT INTO bahrs (BEHR, QALIB, KOD, HECA, trqalib)
VALUES ('ramal', 'Müftə''ilün fA''ilün', '010010101010010101001001010', 11, 'Müfte''ilün fA''ilün');
```

Meter keys must match the `Select Case` in `Utils.bhrName` (lines 40–158) or
the UI renders the string `xeta` — see
[known issue #5](KNOWN_ISSUES.md#5-a-miss-renders-the-literal-string-xeta).

Valid keys: `ramal`, `hazac`, `muzare`, `munsarih`, `mutedarik`, `muqtazab`,
`kamil`, `khafif`, `muctas`, `mutaqarib`, `racaz`, `sari`.

---

## Re-encrypting

If you modify `data/behrdat-plaintext.db` and want to ship it in place of the
original:

```bash
sqlcipher data/behrdat-plaintext.db \
  "ATTACH DATABASE 'new.db' AS enc KEY 'your-password';
   SELECT sqlcipher_export('enc');
   DETACH DATABASE enc;"
```

Then replace `Project/Bahrmetr/B4A/Files/behrdat.db` with `new.db` and update
the `psw` value in `ConnectDB.bas`.

⚠️ If you change the password, note that existing installs will fail to open
the database — there is no migration path in the app.

---

## Provenance

The meter data was compiled by the original author from:

> Şirvani Ədili, *Əruz Vəzninin Sadələşdirilmiş Qəlibləri*

The app's own "About" screen (`Project/Bahrmetr/B4A/aboyt.bas`) credits this
source. Whether that compilation carries its own redistribution rights is a
question for you as the copyright holder of this repository — this document
records the claim as stated by the original work and makes no assertion about
it.

---

## See also

- [README.md](README.md) — how matching uses this data
- [KNOWN_ISSUES.md](KNOWN_ISSUES.md) — bugs affecting matching quality
