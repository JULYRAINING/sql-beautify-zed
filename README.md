# SQL Beautify for Zed

A Windows installer for using the customized SQL formatter bundled with VS Code
extension `clarkyu.vscode-sql-beautify` version `0.3.23` from Zed.

It intentionally vendors the formatter source that the extension actually
loads. This is not equivalent to installing the current npm `vkbeautify`
package: the bundled source contains SQL-specific CASE formatting, quoting,
comment, indentation, and AS-alignment logic.

## Requirements

- Windows
- Node.js LTS, available as `node` in PowerShell
- Zed

## Install

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

## What Zed runs

Zed calls this standard-input/standard-output command:

```text
%USERPROFILE%\.local\bin\sql-beautify-zed.cmd
```

The formatter pins the exact vendored source using SHA-1
`dde215b5ffe988d7e54e383d27e849ca07497412`, so an update to the VS Code
extension cannot change its output.

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
