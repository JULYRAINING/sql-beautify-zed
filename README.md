# SQL Beautify for Zed

[![CI](https://github.com/JULYRAINING/sql-beautify-zed/actions/workflows/ci.yml/badge.svg)](https://github.com/JULYRAINING/sql-beautify-zed/actions/workflows/ci.yml)

Installers for using the customized SQL formatter bundled with VS Code
extension `clarkyu.vscode-sql-beautify` version `0.3.23` from Zed, on Windows,
macOS, and Linux.

Zed has no formatter capability in its extension API (extension API `0.7.0`,
November 2026), so the supported path is `formatter.external`: Zed writes the
buffer to the command's stdin and replaces the buffer with its stdout. This
repository is therefore not a Zed extension and cannot be installed from the
extension marketplace.

It intentionally vendors the formatter source that the extension actually
loads. This is not equivalent to installing the current npm `vkbeautify`
package: the bundled source contains SQL-specific CASE formatting, quoting,
comment, indentation, and AS-alignment logic. This package deliberately raises
the extension's AS-alignment threshold from 150 to 400 columns, so long SELECT
expressions align their aliases strictly.

## Requirements

- Node.js LTS, available as `node`
- Zed
- Windows: PowerShell 5 or newer
- macOS / Linux: a POSIX `sh`

## Install on Windows

Download a release ZIP, extract it, then open PowerShell in the extracted
directory:

```powershell
# Preview paths and prerequisites only.
powershell -ExecutionPolicy Bypass -File .\install.ps1

# Install under %USERPROFILE%\.local and configure Zed.
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Apply
```

The installer backs up an existing Zed settings file before updating its SQL
formatter configuration. Restart Zed after installation.

## Install on macOS and Linux

```sh
./install.sh                    # installs under ~/.local
PREFIX=/usr/local ./install.sh  # or choose another prefix
```

The installer copies:

```text
~/.local/bin/sql-beautify-zed
~/.local/share/sql-beautify-zed/sql-beautify-zed.js
~/.local/share/sql-beautify-zed/configure-zed.js
~/.local/share/sql-beautify-zed/vendor/vkbeautify-0.99.1/
```

It does not edit `settings.json`, because that file often contains comments
the rewrite would drop. Add this to `~/.config/zed/settings.json` (or a
project `.zed/settings.json`):

```json
{
  "languages": {
    "SQL": {
      "format_on_save": "on",
      "formatter": {
        "external": {
          "command": "/Users/you/.local/bin/sql-beautify-zed"
        }
      }
    }
  }
}
```

`formatter.external.command` must be an absolute path; Zed does not expand `~`.
To format on demand instead of on save, drop `format_on_save` and bind
`editor: format`.

To uninstall on macOS or Linux:

```sh
rm -f ~/.local/bin/sql-beautify-zed
rm -rf ~/.local/share/sql-beautify-zed
```

## Verify

```sh
printf "select id,case when status=1 then '正常' else '异常' end as status_name from orders where id=1;" \
  | ~/.local/bin/sql-beautify-zed
```

Expected:

```sql
SELECT  id
       ,CASE WHEN status = 1 THEN '正常'  ELSE '异常' END AS status_name
FROM orders
WHERE id = 1;
```

## What Zed runs

Windows:

```text
%USERPROFILE%\.local\bin\sql-beautify-zed.cmd
```

macOS and Linux:

```text
~/.local/bin/sql-beautify-zed
```

Both launchers resolve the Node wrapper relative to themselves
(`../share/sql-beautify-zed/sql-beautify-zed.js`). If `node` is not on `PATH`
(GUI-launched Zed often lacks the shell's `nvm` path), the macOS/Linux launcher
falls back to the newest `~/.nvm/versions/node/*/bin/node`.

The formatter pins the exact vendored source using SHA-1
`dde215b5ffe988d7e54e383d27e849ca07497412`, so an update to the VS Code
extension cannot change its output.

## Tests

```sh
./test/run.sh
```

The test installs into a temporary prefix and checks the fixtures (basic
query, CTE with aggregates, empty input) plus the installed launcher. CI runs
the same suite on Ubuntu and macOS.

## Example

Input:

```sql
select id,case when status=1 then '正常' else '异常' end as status_name from orders where id=1;
```

Output:

```sql
SELECT  id
       ,CASE WHEN status = 1 THEN '正常'  ELSE '异常' END AS status_name
FROM orders
WHERE id = 1;
```

## Licenses and provenance

The vendored formatter was extracted from the locally installed VS Code
extension above. Its upstream and extension licenses are retained in
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md). The wrapper and installer in
this repository are MIT-licensed; see [LICENSE](LICENSE).

---

## 中文说明

Zed 的扩展 API（`0.7.0`，2026-11）没有格式化器能力，所以本项目不是 Zed 插件，走的是官方支持的
外部格式化器通道：buffer 经 stdin 传入，格式化结果从 stdout 写回。

- **Windows**：`powershell -ExecutionPolicy Bypass -File .\install.ps1 -Apply`
- **macOS / Linux**：`./install.sh`，然后在 `~/.config/zed/settings.json` 的 `languages.SQL`
  下把 `formatter.external.command` 指到 `~/.local/bin/sql-beautify-zed`（必须写绝对路径）。

更新后重新执行安装脚本即可，Zed 配置不需要改。
