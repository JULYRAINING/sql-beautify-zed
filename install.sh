#!/bin/sh
set -eu

repo=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
prefix=${PREFIX:-$HOME/.local}
share="$prefix/share/sql-beautify-zed"

mkdir -p "$prefix/bin" "$share"
install -m 755 "$repo/bin/sql-beautify-zed" "$prefix/bin/sql-beautify-zed"

# Replace the bundled payload so removed/renamed files do not linger.
rm -rf "$share/vendor"
cp -R "$repo/vendor" "$share/vendor"
install -m 644 "$repo/sql-beautify-zed.js" "$share/sql-beautify-zed.js"
install -m 644 "$repo/configure-zed.js" "$share/configure-zed.js"

if ! command -v node >/dev/null 2>&1 && [ ! -d "$HOME/.nvm/versions/node" ]; then
  echo "warning: Node.js was not found. The formatter needs it at runtime." >&2
fi

settings=${ZED_SETTINGS:-$HOME/.config/zed/settings.json}
echo "Installed:"
echo "  $prefix/bin/sql-beautify-zed"
echo "  $share"
echo
echo "Add this to $settings under languages.SQL:"
echo
echo '  "format_on_save": "on",'
echo '  "formatter": {'
echo '    "external": {'
echo "      \"command\": \"$prefix/bin/sql-beautify-zed\""
echo '    }'
echo '  }'
