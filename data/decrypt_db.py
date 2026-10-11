#!/usr/bin/env python3
"""
decrypt_db.py — produce a readable copy of Bahrmetr's SQLCipher database.

The app ships `Project/Bahrmetr/B4A/Files/behrdat.db`, encrypted with
SQLCipher so it cannot be opened with a stock sqlite3 binary. This script
exports an unencrypted copy to `data/behrdat-plaintext.db` so contributors
can read, diff and extend the data without needing a device.

Usage
-----
    python3 -m venv .venv
    ./.venv/bin/pip install sqlcipher3-binary
    ./.venv/bin/python data/decrypt_db.py

or, if you already have the `sqlcipher` CLI:

    sqlcipher Project/Bahrmetr/B4A/Files/behrdat.db \
        "PRAGMA key='<password>'; ATTACH DATABASE 'out.db' AS plain KEY ''; \
         SELECT sqlcipher_export('plain'); DETACH DATABASE plain;"

Password
--------
Read from Project/Bahrmetr/B4A/ConnectDB.bas (the `psw` variable) unless you
pass --password. The B4A SQLCipher library opens this database with
SQLCipher 4 defaults, so the pragmas below must match:

    key derivation   PBKDF2-HMAC-SHA512
    iterations       256000
    page size        4096
    HMAC             SHA-512

Note that the bundled libsqlcipher.so reports version 4.0.0 but still exposes
the SQLCipher 3.x cipher names (aes-256-cbc-hmac-sha1), so do not assume
SHA-1 defaults just because of those strings — the defaults above are what
actually works against this file.
"""

import argparse
import hashlib
import os
import shutil
import sqlite3
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(HERE)
ENCRYPTED = os.path.join(REPO, "Project", "Bahrmetr", "B4A", "Files", "behrdat.db")
PLAINTEXT = os.path.join(HERE, "behrdat-plaintext.db")
CONNECT_DB = os.path.join(REPO, "Project", "Bahrmetr", "B4A", "ConnectDB.bas")


def password_from_source():
    """Scrape the password out of ConnectDB.bas so there is one source of truth."""
    try:
        with open(CONNECT_DB, encoding="utf-8-sig") as fh:
            for line in fh:
                if "psw" in line and "As String" in line and "=" in line:
                    return line.split('"')[1]
    except OSError:
        pass
    return None


def try_sqlcipher3(password):
    try:
        import sqlcipher3
    except ImportError:
        return None, "sqlcipher3 not installed (pip install sqlcipher3-binary)"

    tmp = tempfile.NamedTemporaryFile(suffix=".db", delete=False)
    tmp.close()
    shutil.copy(ENCRYPTED, tmp.name)
    try:
        con = sqlcipher3.connect(tmp.name)
        con.execute("PRAGMA key='%s'" % password)
        con.execute("SELECT count(*) FROM sqlite_master").fetchone()
        out = PLAINTEXT + ".new"
        if os.path.exists(out):
            os.remove(out)
        con.execute("ATTACH DATABASE ? AS plain KEY ''", (out,))
        con.execute("SELECT sqlcipher_export('plain')")
        con.execute("DETACH DATABASE plain")
        con.close()
        return out, None
    except Exception as exc:  # noqa: BLE001
        return None, "%s: %s" % (type(exc).__name__, exc)
    finally:
        os.unlink(tmp.name)


def try_sqlcipher_cli(password):
    import shutil as sh
    import subprocess

    exe = sh.which("sqlcipher")
    if not exe:
        return None, "sqlcipher CLI not found"
    out = PLAINTEXT + ".new"
    if os.path.exists(out):
        os.remove(out)
    script = (
        "PRAGMA key='%s'; "
        "ATTACH DATABASE '%s' AS plain KEY ''; "
        "SELECT sqlcipher_export('plain'); "
        "DETACH DATABASE plain;" % (password, out)
    )
    proc = subprocess.run(
        [exe, ENCRYPTED], input=script, text=True, capture_output=True, check=False
    )
    if proc.returncode != 0 or not os.path.exists(out):
        return None, (proc.stderr or proc.stdout).strip() or "sqlcipher CLI failed"
    return out, None


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--password", help="SQLCipher password (default: read from ConnectDB.bas)")
    ap.add_argument("--force", action="store_true", help="overwrite an existing plaintext copy")
    args = ap.parse_args()

    if not os.path.exists(ENCRYPTED):
        sys.exit("Encrypted database not found: %s" % ENCRYPTED)
    if os.path.exists(PLAINTEXT) and not args.force:
        sys.exit(
            "%s already exists. Re-run with --force to overwrite." % PLAINTEXT
        )

    password = args.password or password_from_source()
    if not password:
        sys.exit("Could not read the password. Pass it with --password.")

    print("Source:      %s" % ENCRYPTED)
    print("Destination: %s" % PLAINTEXT)
    print("Backend:     trying sqlcipher3, then the sqlcipher CLI...")

    result, error = try_sqlcipher3(password)
    if result is None:
        print("  sqlcipher3 unavailable (%s)" % error)
        result, error = try_sqlcipher_cli(password)
    if result is None:
        sys.exit("Decryption failed: %s" % error)

    shutil.move(result, PLAINTEXT)

    with open(PLAINTEXT, "rb") as fh:
        digest = hashlib.sha256(fh.read()).hexdigest()

    con = sqlite3.connect(PLAINTEXT)
    tables = [
        r[0] for r in con.execute("SELECT name FROM sqlite_master WHERE type='table'")
    ]
    print("\nDone.")
    for table in tables:
        count = con.execute('SELECT count(*) FROM [%s]' % table).fetchone()[0]
        print("  %-10s %6d rows" % (table, count))
    print("\n  size:   %d bytes" % os.path.getsize(PLAINTEXT))
    print("  sha256: %s" % digest)
    con.close()


if __name__ == "__main__":
    main()
