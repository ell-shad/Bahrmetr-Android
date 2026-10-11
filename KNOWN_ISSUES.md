# Known issues

This app is published as it shipped. The defects below were found during a
review of the source before publication and have been **deliberately left
unfixed** so that the repository faithfully documents the behaviour of release
1.0.2.

If you are forking this project, these are the things to fix first.

---

## 🔴 Critical — the app can state certainty it does not have

### 1. The "precise match" flag is never reset

**File:** `Project/Bahrmetr/B4XMainPage.bas`
**Lines:** 31 (declaration), 355 and 362 (set), `clrBtn_Click` at 497–505

```basic
Private qelibTapildi, chort As Boolean = False   ' line 31
...
chort = True                                    ' line 355
...
chort = True                                    ' line 362
```

`chort` is set to `True` when an exact match is found, and is **never set back
to `False`** — not in `okBtn_Click`, and not in `clrBtn_Click`. The same is true
of `qelibTapildi`, set at line 253.

**Impact.** Once a user gets one exact hit, every subsequent search that is
*not* an exact hit is still reported as:

> «Dəqiq bəhr tapıldı» / «Kesin vezn bulundu» / **"Precise meter has been found"**

For an app whose entire purpose is accuracy, this is the most damaging defect
in the codebase: it manufactures confidence. The user is told a probabilistic
result is definitive.

**Fix.** Reset both flags at the top of `okBtn_Click`, before `kodla` runs:

```basic
chort = False
qelibTapildi = False
```

---

### 2. The syllable-count guard never executes

**File:** `Project/Bahrmetr/B4XMainPage.bas`
**Lines:** 449, 455, 158–164

`okBtn_Click` sets the guard flag *before* the check that is supposed to test it:

```basic
tapilmadi = False   ' line 449
...
kodla(alfi)         ' line 455
```

Inside `kodla`, the check is wrapped in a test that is already false:

```basic
If tapilmadi = True Then          ' line 158 — always False here
    If hecalar(i) >= 5 Then       ' line 159 — never reached
        tapilmadi = False
    End If
End If
```

**Impact.** The intended minimum-vocabulary rule ("a verse must have at least 5
vowels to be worth matching") is dead code. Very short inputs are fed into the
matcher anyway, producing low-quality results that the UI then presents with
confidence — compounding issue #1.

**Fix.** Remove the `If tapilmadi = True` wrapper, or set `tapilmadi = True` at
the start of `okBtn_Click` instead of `False`.

---

## 🟠 Correctness

### 3. Encoded strings are corrupted for verses ending in a vowel

**File:** `Project/Bahrmetr/B4XMainPage.bas`
**Line:** 149

```basic
If cnt = unspaced.Length Then
    kodlular(i) = kodlular(i) & 10    ' appends TWO characters
Else
    kodlular(i) = kodlular(i) & 1     ' appends ONE character
End If
```

A vowel in the **final** position appends `"10"` where every other position
appends `"1"`.

**Impact.** The encoded string is one character longer than the verse whenever
the verse ends in a vowel. Every downstream comparison — `checkSimilarity`, the
length checks in `qelibTap` — is off by one for that verse. This silently
degrades matching quality and is not visible to the user.

**Fix.** `& 10` should be `& 1`.

---

### 4. Candidates accumulate across verses, skewing the vote

**File:** `Project/Bahrmetr/B4XMainPage.bas`
**Lines:** 274–347 (`checkSimilarity`)

```basic
selected.Initialize        ' once, before the loop
selected2.Initialize      ' once, before the loop
For i = 0 To 2
    ... ExecQuery ...
    selected.Add(...)      ' APPENDS — never cleared between verses
    For Each kod In selected   ' iterates ALL accumulated rows
```

Verse 2 and verse 3 re-vote on verse 1's candidates. In addition, the same
candidate is appended to `selected2` from two places within one iteration —
once inside the `Do While` at line 298, and again after it at line 313.

**Impact.** Because `Utils.axtar` decides the winner by **majority vote**,
duplicate and cross-verse votes bias the result toward whatever loaded first.
Matching accuracy is materially reduced.

**Related.** `selected.Clear` at line 324 is unreachable — it sits after
`Return axtar(selected2)` at line 323.

---

### 5. A miss renders the literal string "xeta"

**File:** `Project/Bahrmetr/B4XMainPage.bas` (`qelibi`, line 377) and
`Project/Bahrmetr/B4A/Utils.bas` (line 157)

When the final lookup returns no row, `a` and `b` remain `""`.
`Utils.bhrName("")` falls through to `Case Else` and returns the debug string
`"xeta"`, which the UI then renders as:

> **Bəhr:xeta**

**Fix.** Guard for an empty `b` in `qelibi` before calling `Utils.bhrName`.

---

### 6. English users get blank pattern names

**Files:** `B4XMainPage.bas` lines 425–443, database `qelibs.enqelib`

`qelibi` selects the display column like this:

```basic
If dil = "Azərbaycanca" Then
    a = ...GetString("qelib")
Else
    a = ...GetString("trqelib")     ' Turkish column, used for BOTH other languages
End If
```

The `qelibs` table has an `enqelib` column, but it is **empty — 0 of 94 rows are
populated.** So in English mode the app shows Turkish pattern names, and any
future English data would still be ignored.

**Fix.** Read `enqelib` for `dil = "English"`, and populate the column. The data
side can be fixed without touching application logic — see [DATA.md](DATA.md).

---

## 🟡 Robustness

### 7. SQL is built by string concatenation

**File:** `Project/Bahrmetr/B4XMainPage.bas` — lines 229, 280, 385, 406

```basic
ConnectDB.resul = ConnectDB.varSQL.ExecQuery( _
    "SELECT * FROM qelibs WHERE digqel =" & $"""$ & kod & $"""$)
```

The values interpolated here come from the database itself, so there is no
practical injection risk in the shipped app. It is still the wrong pattern, and
notably `DBUtils.bas` — which *does* use bound parameters via `ExecQuery2` — sits
unused in the same project.

**Also.** All four queries use `SELECT *` while reading only two or three
columns.

---

### 8. `Utils.axtar` updates the winner mid-count

**File:** `Project/Bahrmetr/B4A/Utils.bas` — lines 15–34

```basic
For j = 0 To kods.Size - 1
    If kods.Get(j) = tmp Then tmpCount = tmpCount + 1
    If tmpCount > count Then element = tmp : count = tmpCount   ' inside inner loop
Next
```

`count` is updated *during* counting, so `element` churns on each iteration
rather than settling. The final answer is correct, but the function cannot be
read or reasoned about. Move the `If` after the inner loop.

---

### 9. Database opened with no error handling

**File:** `Project/Bahrmetr/B4A/ConnectDB.bas` — lines 17–25

`ConnectionToDB` wraps everything in `Try / Log(LastException)`. If the copy or
open fails, `varSQL` stays uninitialised and every later query throws.

---

### 10. No indexes on the columns every query filters on

**File:** `Project/Bahrmetr/B4A/Files/behrdat.db`

Neither `bahrs.HECA` nor `qelibs.hga` is indexed:

```sql
SELECT * FROM qelibs WHERE hga = ?
SELECT * FROM bahrs  WHERE HECA = ?
```

Each search is a full table scan over 3,467 rows. Harmless at this size, but it
is the first thing to add if the dataset grows — see [DATA.md](DATA.md).

---

## 🔵 Hygiene

### Dead code

Two modules are present in `Project/Bahrmetr/B4A/` but are **not** in the
compiled module list (`Module1`–`Module6` in `Bahrmetr.b4a`). They do not
affect the build:

| File | Lines | Note |
|---|---:|---|
| `Localizator.bas` | 163 | DB-backed i18n; needs `strings.db`, which does not exist |
| `ConnectionDB.bas` | 30 | Superseded by `ConnectDB.bas`; references `B4XPages.MainPage.SQL`, a member that does not exist, so it would crash if called |

They are left in place deliberately — `Localizator.bas` is a working i18n
implementation that a fork wanting to externalise the hard-coded strings could
adopt.

Also unused: `Files/lang.bal`, `Files/g5145.png`, and `Shared Files/` (empty —
though `B4XMainPage.bas:8` still has a Robocopy step pointing at it).

`DBUtils.bas` is a stock B4X utility library; only `CopyDBFromAssets` is called.

Three further modules that used to sit here — `AdsHelper.bas`, `mwNative.bas`
and `B4XNative2.bas` — were deleted when the ad stack was removed. See
[SECURITY.md](SECURITY.md#google-admob).

### Other

- `minSdkVersion="5"` while the bundled AndroidX artifacts of that era require
  API 19–21+. Expect crashes on very old devices.
- `B4J/` and `B4i/` are untouched B4X templates pointing at Android-only shared
  code. Neither can compile. Left in place and documented; see
  [BUILD.md](BUILD.md#b4j-and-b4i).
- `B4XMainPage.bas` carries 17 module-level mutable variables that leak state
  between calls. This is the underlying cause of issues #1 and #4.

---

## Algorithm caveats

Independent of any bug, the approach has inherent limits worth stating plainly:

- **Vowel-only encoding.** Consonant identity is discarded entirely. Two verses
  with identical vowel skeletons are indistinguishable, however different their
  consonants.
- **Latin-script only.** The app's own "About" text advises replacing Persian
  and Arabic characters (`à ǻ ḁ ǜ ǘ ǚ ĕ ḝ ȇ`) with Latin equivalents. It cannot
  process Arabic script at all.
- **Vowel set is Azerbaijani-centric** — `a e i o u ə ö ü ı`. Turkish and Persian
  texts using other vowels are miscounted.
- **Three verses is a heuristic minimum,** not a guarantee. The matching is
  similarity-based, not a solver: it does not enumerate prosodic possibilities,
  so a correct meter can be missed and an incorrect one matched.

The dataset is also unvalidated — `PRAGMA integrity_check` passes, but there are
**no indexes** on `bahrs.HECA` or `qelibs.hga`, the two columns every query
filters on, so each search is a full table scan.

---

## See also

- [README.md](README.md) — overview
- [BUILD.md](BUILD.md) — compiling this today
- [DATA.md](DATA.md) — database contents
- [CONTRIBUTING.md](CONTRIBUTING.md)
