#!/usr/bin/env sh
# Build a clean, installable eyerest.koplugin.zip containing only the files the
# plugin needs at runtime — no tests/, no assets/, and the folder is named
# exactly "eyerest.koplugin" (no version suffix), as KOReader requires.
set -e
cd "$(dirname "$0")"

RUNTIME="_meta.lua main.lua breaklogic.lua breakview.lua alarmview.lua README.md LICENSE"
OUT="dist"

rm -rf "$OUT"
mkdir -p "$OUT/eyerest.koplugin"
cp $RUNTIME "$OUT/eyerest.koplugin/"
( cd "$OUT" && zip -rqX eyerest.koplugin.zip eyerest.koplugin )

echo "built $OUT/eyerest.koplugin.zip"
unzip -l "$OUT/eyerest.koplugin.zip"
