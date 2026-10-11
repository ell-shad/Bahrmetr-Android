# Security notes

This repository was prepared for public release. The notes below record what
was found, what was done, and what is left for you to decide.

---

## Summary

| Finding | Status |
|---|---|
| SQLCipher password in `ConnectDB.bas` | ✅ Removed, along with all encryption |
| Live Firebase API key in `google-services.json` | ✅ Removed — file excluded entirely |
| AdMob production IDs in `Bahrmetr.b4a` | ✅ Removed |
| Firebase Analytics + Cloud Messaging | ✅ Removed (unused, same library as AdMob) |
| Ad modules (`AdsHelper`, `mwNative`, `B4XNative2`) | ✅ Deleted |
| Signed `.aab` with your certificate | ✅ Excluded |
| `d8_arguments.txt` leaking `C:\Users\<name>\...` | ✅ Excluded |
| 41.7 MB of build output | ✅ Excluded |
| No LICENSE | ✅ Added (GPL-3.0) |
| No ad consent flow (UMP) | ✅ Moot — ads removed |
| No `SECURITY.md` | ✅ This file |

**The published project now has no secrets, no network code, no tracking, and
no encryption.**

---

## What was removed, and why

### SQLCipher encryption

The database shipped encrypted with a password hard-coded in the source:

```basic
' Project/Bahrmetr/B4A/ConnectDB.bas:14 (removed)
Private psw As String = "masmililer123!5"
```

The encrypted file shipped **inside the APK** and the password shipped in the
source that built it. Anyone could unzip the app, read the password and decrypt
the data. The encryption provided no confidentiality, and cost roughly 11 MB of
native `.so` libraries across five ABIs.

**What changed**

| | Before | After |
|---|---|---|
| `ConnectDB.bas` | `Dim varSQL As SQLCipher` | `Dim varSQL As SQL` |
| `ConnectDB.bas` | `varSQL.Initialize(..., True, psw, Null)` | `varSQL.Initialize(..., False)` |
| `ConnectDB.bas` | `Private psw As String = "..."` | *removed* |
| `Bahrmetr.b4a` | `Library7=sqlcipher` | *removed* (7 libraries → 5) |

**The data is unchanged.** Every row of both tables and both schema definitions
were verified byte-for-byte identical against the original encrypted file before
the swap — 3,467 `bahrs` rows, 94 `qelibs` rows, `PRAGMA integrity_check` = `ok`.

### Google AdMob

Removed from `Bahrmetr.b4a`:

- `Library3=firebaseadmob2` (libraries renumbered, `NumberOfLibraries` 7 → 5)
- `CreateResourceFromFile(Macro, FirebaseAdMob.FirebaseAds)`
- `AddReplacement($ADMOB_APP_ID$, ca-app-pub-8118319368008476~9500219955)`
- The `BannerAd` field in `Sub Globals`
- The banner construction and `Activity.AddView` block in `Activity_Create`
- `Sub GetAdaptiveAdSize`
- `Sub Ad_ReceiveAd`, `Ad_FailedToReceiveAd`, `Ad_AdClosed`, `Ad_AdOpened`

Deleted outright:

| File | Lines | Why |
|---|---:|---|
| `AdsHelper.bas` | 493 | AdMob consent (UMP) — moot without ads |
| `mwNative.bas` | 197 | Native ad renderer |
| `B4XNative2.bas` | 41 | Native ad page, not registered |

The banner had real defects anyway — no failure callback, never removed on
pause, and absolute positioning that overlaid the B4XPages root. See
[KNOWN_ISSUES.md](KNOWN_ISSUES.md).

### Firebase Analytics and Cloud Messaging

`firebaseadmob2` was the **only** Google library in the project, and it supplied
all three manifest macros. Removing it therefore meant removing:

```
CreateResourceFromFile(Macro, FirebaseAnalytics.GooglePlayBase)
CreateResourceFromFile(Macro, FirebaseAnalytics.Firebase)
CreateResourceFromFile(Macro, FirebaseNotifications.FirebaseNotifications)
CreateResourceFromFile(Macro, FirebaseAnalytics.FirebaseAnalytics)
```

Neither Analytics nor FCM was ever called by application code — both existed
only to measure ad performance. Both are gone, along with:

- `Project/Bahrmetr/B4A/google-services.json` (excluded, and the `.example`
  template deleted since there is nothing left to configure)
- The `INTERNET`, `ACCESS_NETWORK_STATE`, `AD_ID`, `FOREGROUND_SERVICE`,
  `WAKE_LOCK`, `c2dm.RECEIVE` and `BIND_GET_INSTALL_REFERRER_SERVICE`
  permissions, which were all injected by those libraries

> The permission list above is from the **generated** manifest in the excluded
> `Objects/` tree. Regenerate the manifest by building once and confirm the
> result — an offline app should need no permissions at all.

### Ad consent (UMP) — resolved

The shipped app requested ads with **no consent collection**, including for
users in the EEA/UK, while 493 lines of unused UMP code sat in the project. That
is a real GDPR exposure. It is moot now that ads are gone.

---

## What remains

### Your signing certificate

The shipped `Objects/Bahrmetr.aab` was signed with a certificate issued to:

```
CN=Elshad Guliyev, O=Coriolis, C=AZ
SHA256: E8:73:46:99:A5:97:AC:50:41:EF:3D:72:BC:06:E6:9F:3F:CE:DA:EF:21:18:D1:CF:1E:21:1F:05:E1:0F:2B:00
Valid: 2022-03-08 → 2060-07-06
```

The `.aab` is excluded, as are `*.keystore`, `*.jks`, `*.p12` and friends.

The **private** key was not in the source tree and remains safe. But if you ever
committed a keystore to a previous repository, check that repository's history
before assuming it is still private.

### The Firebase API key is still recoverable

The old `google-services.json` contained a live API key. It is excluded from
git, but **removing the file does not unpublish the key** — it was embedded in
every release of the app and is visible in the shipped APK.

**If that key has API access you care about, rotate it in the Firebase
console.** Nothing in the current project depends on Firebase, so rotating it
breaks nothing. Restricting it by package name and API in the Google Cloud
console is the more important control either way.

---

## Machine-local paths

`Objects/d8_arguments.txt` contained **510 lines** of absolute Windows paths
including `C:\Users\Elshad Guliyev\Desktop\projets\Project\Bahrmetr\`. Excluded
via `.gitignore`, and the relevant environment details were distilled into
[BUILD.md](BUILD.md#recovered-build-environment) instead.

---

## Open concerns

### `minSdkVersion="5"`

Set in `Bahrmetr.b4a`, while the bundled AndroidX artifacts of that era required
API 19–21 or higher. Now that the Google libraries are gone this is less
pressing, but it should still be raised.

---

## Reporting a vulnerability

This is an archived, unmaintained project. There is no supported disclosure
channel and no guarantee of a response.

The actively developed successor is the [web app](https://bahrmetr.netlify.app/)
([source](https://github.com/ell-shad/Bahrmetr)) — security issues affecting
that project should be raised in its own repository.

If you find a security issue in *this* code, open a GitHub issue describing it —
for an archived project that is proportionate. Please do not publish exploit
details for anything affecting users of the published Android app before the
maintainer has had a chance to react.

---

## Before you publish

- [x] `.gitignore` covers build output, keys and OS cruft
- [x] `.gitattributes` prevents git rewriting the IDE's CRLF+BOM files
- [x] No encryption, no password, no secrets
- [x] No AdMob, no Firebase, no tracking, no network code
- [x] No signed artifacts or absolute paths from the original machine
- [x] LICENSE added
- [ ] **Rotate the Firebase API key** — it is still recoverable from any installed copy
- [ ] **Build once and confirm the generated manifest requests no permissions**

---

## See also

- [BUILD.md](BUILD.md) — build and signing setup
- [DATA.md](DATA.md) — the database
- [KNOWN_ISSUES.md](KNOWN_ISSUES.md)
