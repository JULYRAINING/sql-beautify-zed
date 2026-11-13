#!/bin/sh
set -eu

repo=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
fail=0

# Install into a throwaway prefix so the test covers the same launcher and
# payload layout that users get.
PREFIX="$tmp/prefix" "$repo/install.sh" > "$tmp/install.log"
formatter="$tmp/prefix/bin/sql-beautify-zed"

run_one() {
  name=$1
  out="$tmp/$name.out"
  err="$tmp/$name.err"

  if ! "$formatter" < "$repo/test/fixtures/$name.sql" > "$out" 2> "$err"; then
    echo "FAIL $name: non-zero exit"
    cat "$err"
    fail=1
    return
  fi

  if [ -s "$err" ]; then
    echo "FAIL $name: wrote to stderr"
    cat "$err"
    fail=1
  fi

  if diff -u "$repo/test/expected/$name.sql" "$out"; then
    echo "ok $name"
  else
    echo "FAIL $name: output mismatch"
    fail=1
  fi
}

for fixture in "$repo"/test/fixtures/*.sql; do
  name=$(basename "$fixture" .sql)
  run_one "$name"
done

exit "$fail"
