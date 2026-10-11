# Contributing

Bahrmetr is published as an **unmaintained legacy release**. Bug reports,
algorithm corrections and dataset additions are still very welcome — but you
should expect to set up your own environment, and to do your own verification.

> **The actively developed version is the [web app](https://bahrmetr.netlify.app/)**
> ([source](https://github.com/ell-shad/Bahrmetr), MIT licensed). Feature requests
> and general bug reports for everyday use are better directed there. This
> repository is for the historical Android release and anyone forking it.

If you are looking for a maintained aruz tool, use the web app.

---

## What is useful

In rough order of value:

1. **Fixing the correctness bugs** listed in
   [KNOWN_ISSUES.md](KNOWN_ISSUES.md). Issue #1 — the "precise match" flag that
   is never reset — is the one that matters most, because the app currently
   tells users a guess is a certainty.
2. **Populating `qelibs.enqelib`.** Currently 0 of 94 rows. Pure data work, no
   code changes required. See [DATA.md](DATA.md#data-quality-notes).
3. **Adding meter patterns.** See [DATA.md](DATA.md#extending-the-data).
4. **Adding indexes** on `bahrs.HECA` and `qelibs.hga` — every search is a full
   table scan today. See [DATA.md](DATA.md#adding-indexes).
5. **Making it actually build.** See [BUILD.md](BUILD.md); it does not compile
   as-is.
6. **Documentation.** Especially of the matching algorithm — see below.

---

## Before you open a pull request

This project has **no CI**, and the code is a format most tooling cannot parse.

- [ ] Read [KNOWN_ISSUES.md](KNOWN_ISSUES.md) so you do not "fix" something that
      was left broken on purpose.
- [ ] If you change application logic, say which known issues your change
      resolves, and which it deliberately leaves.
- [ ] If you change the database, update the row counts and schema notes in
      [DATA.md](DATA.md).
- [ ] Confirm you have not committed anything from [SECURITY.md](SECURITY.md).
- [ ] Keep changes focused. This is a small codebase; large refactors are hard
      to review without a working build.

---

## Code style

There is no enforced style — the code is formatted by the B4X IDE's default
settings. Match what is already there:

- **Tabs** for indentation, never spaces.
- **UTF-8 with BOM**, **CRLF** line endings. This is what the IDE writes, and
  `.gitattributes` sets `-text` on `*.bas` / `*.b4a` / `*.b4j` / `*.b4i` so git
  will not rewrite them. **Do not reformat line endings or strip the BOM** —
  the IDE will flag the file as externally modified.
- Lowercase `If` / `For` / `Next` / `End If` as the original author used them.
- One `Sub` per logical operation; add a blank line between subs.

### A note on language

Variable and method names are a mix of Azerbaijani, Turkish and English
(`kodla`, `qelib`, `misra`, `hecalar`, `behrName`, `checkSimilarity`). This is
authentic to the codebase and is **not** an invitation to normalise it —
translations would obscure the connection to the prosodic terminology, which is
the point of the naming. Document new code in English.

---

## Local setup

```bash
git clone <your-fork>
cd bahrmetr
```

To build the app you need **Windows** and a **paid B4A subscription**. There is
no Firebase project to set up, no API key, and no database password. See
[BUILD.md](BUILD.md).

---

## Working on the dataset

The database lives at `Project/Bahrmetr/B4A/Files/behrdat.db`. It is a **plain
SQLite file** — no password, no SQLCipher:

```bash
sqlite3 Project/Bahrmetr/B4A/Files/behrdat.db
```

Schema is in [DATA.md](DATA.md#schema). Please keep the two tables' existing
column naming conventions when adding rows, and update
[DATA.md](DATA.md#contents) if you change row counts.

If you add patterns, please say **where they came from** — a citation, a
corpus, or your own derivation. Provenance matters for a linguistic dataset
more than for most others.

---

## Documenting the algorithm

This is the single biggest gap in this repository.

The matching logic in `Project/Bahrmetr/B4XMainPage.bas` is described in
[README.md](README.md#how-it-works) at the level the author left it: encoding,
then canonical match, then fallback, then majority vote. Several details are
**not** recoverable from the source with confidence — for example, why the
thresholds are 0.75, 0.5 and 0.85, and how they were chosen.

If you know these, or can work them out empirically, that documentation would be
the most valuable contribution anyone could make here.

---

## Reporting bugs

Open an issue with:

- What you entered (the three verses, if you can share them)
- What the app returned
- What you believe the correct meter is
- Device and Android version

A reproducible example is worth more than a description.

Because there is no CI and no test suite, please include your verification steps
in the pull request description. **A bug fix without evidence it works will not
be merged.**

---

## Reporting security issues

See [SECURITY.md](SECURITY.md#reporting-a-vulnerability).

---

## License

Contributions are accepted under **GPL-3.0**, the same license as the project.
By opening a pull request you confirm you have the right to license your
contribution under it.

Note that B4X libraries are **not** covered by this license — see
[BUILD.md](BUILD.md#library-licensing).
