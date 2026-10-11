# Building Bahrmetr

This app was last built on **3 September 2023** on Windows with **B4X IDE
12.5**. This document records what is needed to reproduce that build, and —
importantly — what is **missing** from this repository.

> **Short version:** you need Windows + a licensed B4X IDE and your own signing
> keystore. There is no Firebase project to set up, no API key to supply, and no
> database password — the app is fully offline.

---

## Requirements

| | |
|---|---|
| **OS** | Windows 10/11 — B4X is Windows-only, and this project hard-codes Robocopy (see [below](#windows-only-references)) |
| **IDE** | [B4X IDE](https://www.b4x.com/b4a.html) 12.5 or later |
| **License** | B4X is commercial. A **paid B4A subscription is required** to compile an Android app. The IDE will not build without one. |
| **JDK** | Bundled with B4X; nothing to install separately |
| **Android SDK** | Platform 33 (`android-33`) — see [`d8_arguments.txt` reconstruction](#recovered-build-environment) |

**No other setup is required.** The published app has no network dependency, no
analytics, no ads, and no encryption. `google-services.json` is not needed and is
not part of the project.

---

## Steps

### 1. Install B4X IDE

Download and install B4X IDE, then install the **B4A** target from the IDE's
 Libraries menu.

### 2. Open the project

```
Project/Bahrmetr/B4A/Bahrmetr.b4a
```

The project declares these five libraries:

| # | Library | Pulled in by |
|---|---|---|
| 1 | `b4xpages` | B4XPages multi-page framework |
| 2 | `core` | Core types and runtime |
| 3 | `runtimepermissions` | Runtime permissions (AndroidX) |
| 4 | `sql` | SQLite access |
| 5 | `xui views` | B4X cross-platform view library |

Two libraries that the shipped app depended on have been **removed** and are no
longer downloaded:

- **`sqlcipher`** — the database is plain SQLite now.
- **`firebaseadmob2`** — the ad and analytics stack was removed entirely.

If you are comparing against the original release, note that removing
`firebaseadmob2` also removed the Firebase Analytics and Cloud Messaging
manifest macros, since all three were supplied by that one library. Neither
Analytics nor FCM was actually used by the app.

### 3. Let the IDE download the libraries — **read this first**

⚠️ **`Project/Bahrmetr/B4A/Objects/b4xlibs/` is not committed.** It contains
only a `Files/` folder holding the dialog `.bal` templates; the library
definitions themselves are absent.

This is partly by design — B4X libraries are third-party code, and the
`Objects/` tree is gitignored (see `.gitignore`). But it has a consequence you
must understand:

**B4X re-resolves library versions from the online library at open time.**
You will get whatever the current release of each library is, *not* what this
app was built against. A future library update can break the build with no
change on your side, and there is no lockfile to prevent it.

The versions this project actually shipped with were recovered from the build
artifacts and are recorded in
[Recovered build environment](#recovered-build-environment) below. If you need a
reproducible build, download those specific library versions and commit their
`.xml`/`.bas` definitions into `Objects/b4xlibs/` yourself.

B4X libraries are distributed under the B4X EULA and are **not** covered by this
project's GPL-3.0 license. See [Library licensing](#library-licensing).

### 4. Provide your own signing keystore

**No keystore is committed, and none should ever be.** Generate your own:

```bash
keytool -genkeypair -v -keystore my-release-key.jks \
  -alias my-alias -keyalg RSA -keysize 2048 -validity 10000
```

Configure it in the B4X IDE under *Configure → Default Keys*.

The signed `Bahrmetr.aab` that shipped with the app was signed with a
certificate issued to `CN=Elshad Guliyev, O=Coriolis, C=AZ`, valid until 2060.
That certificate's public half is recoverable from any copy of the app.

### 5. Build

That is the whole setup. There is nothing to configure.

---

## Windows-only references

Two hard-coded Windows dependencies remain in the source:

**`Project/Bahrmetr/B4XMainPage.bas:8`**

```basic
#CustomBuildAction: folders ready, %WINDIR%\System32\Robocopy.exe,"..\..\Shared Files" "..\Files"
```

This syncs an **empty** directory (`Shared Files/`) into `B4A/Files/`. It does
nothing useful and will fail on any non-Windows system. It can be deleted
safely, or replaced with a no-op.

**`Project/Bahrmetr/B4A/Bahrmetr.b4a:20`**

```
Module2=|relative|..\B4XMainPage
```

The shared-module path uses a backslash separator. B4X on Windows handles this
fine; the B4X IDE is Windows-only regardless.

---

## B4J and B4i

`Project/Bahrmetr/B4J/` and `Project/Bahrmetr/B4i/` are **untouched B4X project
templates**. Both point their `Module1` at `..\B4XMainPage`, which is saturated
with Android-only types — `B4AMenuItem`, `B4AFloatTextField`, `Label`, `Panel`,
`Colors`.

**Neither can compile, and never did.** Their layout files still contain the
stock template with a single `Button1` control.

They are retained for historical completeness and as a starting point if
someone wants to make the app cross-platform. Doing so requires guarding the
whole of `B4XMainPage.bas` with `#if B4A` / `#else if B4J` / `#else if B4i` and
rewriting the UI layer, since the shared module is Android-specific throughout.

---

## Recovered build environment

The following was reconstructed from `Objects/d8_arguments.txt`, which is
gitignored because it embeds absolute paths from the original machine
(`C:\Users\Elshad Guliyev\Desktop\projets\...`).

> These are the versions from the **original** build, which still included the
> SQLCipher and Firebase/AdMob libraries that have since been removed. Only the
> B4X library entries are relevant to the project as it now stands; the Google
> and AndroidX entries are kept for reference.

**Toolchain**

| | |
|---|---|
| Android platform | `android-33` (`targetSdkVersion 33`) |
| `minSdkVersion` | `5` — see [known issue](KNOWN_ISSUES.md#other) |
| SQLCipher | `android-database-sqlcipher` 4.0.0 — **no longer used** |

**B4X library versions** (trailing number is the B4X library build ID)

```
b4ashared          63822315362000     <- core
sql                63822315364000
stringutils        63822315364000
xui                63822315364000     <- xui views
xcustomlistview    63822315364000
runtimepermissions.androidx 63822315362000
bitmapcreator      63822315362000
dateutils          63822315362000
ime                63822315362000
javaobject         63822315362000

removed:
  sqlcipher                       63679891102000
  firebaseadmob2                  63822315362000
```

**Google Play services / Firebase artifacts** — *all no longer used*

```
play-services-ads               21.3.0      firebase-ads          21.3.0
play-services-ads-base          21.3.0      firebase-analytics    21.2.0
play-services-ads-lite          21.3.0      firebase-common       20.0.0
play-services-ads-identifier    18.0.1      firebase-components   17.0.1
play-services-base              18.1.0      firebase-installations 17.1.0
play-services-basement          18.1.0      user-messaging-platform 2.0.0
play-services-tasks              18.0.2
```

**AndroidX**

```
activity            1.6.1      core                1.9.0
activity-ktx        1.6.1      core-ktx            1.9.0
fragment            1.5.4      core-runtime         2.1.0
lifecycle-*         2.5.1      savedstate(-ktx)     1.2.0
browser             1.4.0      annotation-exp.      1.3.0
documentfile        1.0.1      loader               1.1.0
localbroadcastmgr   1.1.0      versionedparcelable  1.1.1
viewpager           1.0.0      work-runtime         2.5.0
legacy-support-core-utils       1.0.0
customview          1.1.0      print                1.0.0
```

---

## Library licensing

The B4X libraries (B4XPages, XUI Views, RuntimePermissions, and the
AndroidX artifacts they pull in) are **third-party components with their own
licenses** — the B4X EULA and the Apache 2.0 license respectively.

This repository's GPL-3.0 license covers **only the Bahrmetr source code you
see under `Project/`**. It does not relicense any bundled library.

The B4X `*.b4a` project file format and the B4A runtime are products of
[Erel / B4X](https://www.b4x.com/) and are covered by the B4X EULA. This
project is not affiliated with or endorsed by B4X.

---

## Troubleshooting

**"Library not found" after opening the project**
Expected — `b4xlibs/` is not committed. Let the IDE download them, or restore
them from a build of the original.

**Robocopy error during build**
Delete the `#CustomBuildAction` line at `B4XMainPage.bas:8`. It targets an
empty directory and is not needed.

**`Cannot resolve symbol` / undefined types**
The IDE is resolving newer library versions than the app was written against.
Check [the version list above](#b4x-library-versions-trailing-number-is-the-b4x-library-build-id)
and pin matching versions.

**`String is not a database` at startup**
You have an encrypted copy of `Files/behrdat.db` from the original release.
The project expects a plain SQLite file. Decrypt it, or take the copy from this
repository — see [DATA.md](DATA.md).

---

## See also

- [KNOWN_ISSUES.md](KNOWN_ISSUES.md) — defects to fix before trusting results
- [DATA.md](DATA.md) — the database
- [SECURITY.md](SECURITY.md) — what was removed before publishing
