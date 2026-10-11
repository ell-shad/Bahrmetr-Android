# Security notes

This repository was prepared for public release. The notes below record what
was found, what was done, and what is left for you to decide.

---

## Summary

| Finding | Status |
|---|---|
| Live Firebase API key in `google-services.json` | ✅ Removed — gitignored, template provided |
| SQLCipher password in `ConnectDB.bas` | ⚠️ Still present — source left untouched by request |
| AdMob production IDs in `Bahrmetr.b4a` | ⚠️ Still present — source left untouched by request |
| Signed `.aab` with your certificate | ✅ Excluded |
| `d8_arguments.txt` leaking `C:\Users\<name>\...` | ✅ Excluded |
| 41.7 MB of build output | ✅ Excluded |
| No LICENSE | ✅ Added (GPL-3.0) |
| No ad consent flow (UMP) in the shipped app | ⚠️ Documented, not fixed |
| No `SECURITY.md` | ✅ This file |

---

## What was removed

### Firebase credentials

`Project/Bahrmetr/B4A/google-services.json` contained a live API key, project
number and OAuth client ID. It is now gitignored. A template is provided at
`Project/Bahrmetr/B4A/google-services.json.example`.

**Important:** removing the file from git does not unpublish the key. It was
already distributed inside every release of the app, and Firebase API keys are
visible in the shipped APK. If that key has API access you care about,
**rotate it in the Firebase console** — restricting it by package name and API
in the Google Cloud console is the more important control either way.

### Signed build artifacts

The shipped `Objects/Bahrmetr.aab` was signed with a certificate issued to:

```
CN=Elshad Guliyev, O=Coriolis, C=AZ
SHA256: E8:73:46:99:A5:97:AC:50:41:EF:3D:72:BC:06:E6:9F:3F:CE:DA:EF:21:18:D1:CF:1E:21:1F:05:E1:0F:2B:00
Valid: 2022-03-08 → 2060-07-06
```

The `.aab` is now excluded, as are `*.keystore`, `*.jks`, `*.p12` and friends.

The **private** key was not in the source tree and remains safe. But if you ever
committed a keystore to a previous repository, check that repository's history
before assuming it is still private.

### Machine-local paths

`Objects/d8_arguments.txt` contained **510 lines** of absolute Windows paths
including `C:\Users\Elshad Guliyev\Desktop\projets\Project\Bahrmetr\`. Excluded
via `.gitignore`, and the relevant environment details were distilled into
[BUILD.md](BUILD.md#recovered-build-environment) instead.

---

## What is still in the repository, and why

You asked that application source stay untouched. These items were therefore
left in place:

### SQLCipher password — `Project/Bahrmetr/B4A/ConnectDB.bas:14`

```basic
Private psw As String = "masmililer123!5"
```

The database ships **inside the APK** and the password ships in the source that
built it. The encryption provides no confidentiality whatsoever — anyone can
unzip the app and decrypt `behrdat.db`.

Because a plaintext copy is also committed at `data/behrdat-plaintext.db`, the
data is openly readable regardless. See [DATA.md](DATA.md#-the-encryption-provides-no-confidentiality).

**Recommendation for a fork:** either drop SQLCipher and ship a plain SQLite
file — saving ~11 MB of native libraries across five ABIs — or move the key out
of the source. Do not ship it as-is and describe it as encryption.

### AdMob IDs — `Project/Bahrmetr/B4A/Bahrmetr.b4a`

```
App ID:   ca-app-pub-8118319368008476~9500219955
Banner:   ca-app-pub-8118319368008476/5187130926
```

AdMob publisher IDs are semi-public — they appear in the manifest of every
installed copy. They are not secrets in the way an API key is.

**If you fork this and publish your own app**, replace both with your own, and
use Google's [test ad unit IDs](https://developers.google.com/admob/android/test-ads)
during development. Running production ads from a forked app against the
original's ad unit risks invalid-traffic suspension for *your* AdMob account.

---

## Open concerns

### Ad consent (UMP) is not wired up

`Project/Bahrmetr/B4A/AdsHelper.bas` contains 493 lines of AdMob User Messaging
Platform consent-management code. It is **not in the compiled module list** —
`Bahrmetr.b4a` lists only six modules, and `AdsHelper` is not among them.

The shipped app therefore requests ads with **no consent collection**, including
for users in the EEA/UK. Google's UMP integration is required for AdMob to serve
in those regions.

If you publish a fork with ads in the EU, wire `AdsHelper.bas` up first, or
consider removing ads entirely — a prosody reference tool is a perfectly good
ad-free app.

### `minSdkVersion="5"`

Set in `Bahrmetr.b4a` and generated `AndroidManifest.xml`, while the bundled
AdMob 21.3.0 and Firebase artifacts require API 19–21 or higher. Expect crashes
on very old devices.

### No permissions beyond the required set

The generated manifest requests only:

```
INTERNET
ACCESS_NETWORK_STATE
AD_ID
FOREGROUND_SERVICE
WAKE_LOCK
c2dm.RECEIVE
BIND_GET_INSTALL_REFERRER_SERVICE
```

No location, contacts, storage, camera or microphone. For an offline
pattern-matching app with ads, that is a reasonable minimum. `FOREGROUND_SERVICE`
and `WAKE_LOCK` come from the Firebase Notifications library, which this app
does not otherwise use — they could likely be dropped.

---

## Reporting a vulnerability

This is an archived, unmaintained project. There is no supported disclosure
channel and no guarantee of a response.

If you find a security issue, open a GitHub issue describing it — for an archived
project that is proportionate. Please do not publish exploit details for
anything affecting users of the published app before the maintainer has had a
chance to react.

---

## Before you publish

- [x] `.gitignore` covers build output, keys, Firebase config, OS cruft
- [x] `.gitattributes` prevents git rewriting the IDE's CRLF+BOM files
- [x] `google-services.json` excluded, template provided
- [x] No keystore, `.aab`, or `.apk` committed
- [x] No absolute paths from the original machine
- [x] LICENSE added
- [ ] **Consider rotating the Firebase API key** if it has API access you care about
- [ ] **Decide whether to publish a fork with ads** — if so, get your own AdMob account and consent flow

---

## See also

- [BUILD.md](BUILD.md) — build and signing setup
- [DATA.md](DATA.md) — database and its encryption
- [KNOWN_ISSUES.md](KNOWN_ISSUES.md)
