@echo off
setlocal
where node >nul 2>nul
if errorlevel 1 (
  echo sql-beautify-zed: Node.js was not found on PATH. Install Node.js LTS and retry. 1>&2
  exit /b 127
)
node "%~dp0..\share\sql-beautify-zed\sql-beautify-zed.js"
