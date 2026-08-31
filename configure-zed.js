#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');

function stripJsonc(text) {
  let result = '';
  let inString = false;
  let escaped = false;
  for (let index = 0; index < text.length; index += 1) {
    const char = text[index];
    const next = text[index + 1];
    if (inString) {
      result += char;
      if (escaped) escaped = false;
      else if (char === '\\') escaped = true;
      else if (char === '"') inString = false;
      continue;
    }
    if (char === '"') {
      inString = true;
      result += char;
    } else if (char === '/' && next === '/') {
      while (index < text.length && text[index] !== '\n') index += 1;
      result += '\n';
    } else if (char === '/' && next === '*') {
      index += 2;
      while (index < text.length && !(text[index] === '*' && text[index + 1] === '/')) index += 1;
      index += 1;
    } else {
      result += char;
    }
  }

  let withoutTrailingCommas = '';
  inString = false;
  escaped = false;
  for (let index = 0; index < result.length; index += 1) {
    const char = result[index];
    if (inString) {
      withoutTrailingCommas += char;
      if (escaped) escaped = false;
      else if (char === '\\') escaped = true;
      else if (char === '"') inString = false;
      continue;
    }
    if (char === '"') {
      inString = true;
      withoutTrailingCommas += char;
    } else if (char === ',') {
      let next = index + 1;
      while (/\s/.test(result[next] || '')) next += 1;
      if (result[next] !== '}' && result[next] !== ']') withoutTrailingCommas += char;
    } else {
      withoutTrailingCommas += char;
    }
  }
  return withoutTrailingCommas;
}

const [settingsPath, commandPath] = process.argv.slice(2);
if (!settingsPath || !commandPath) {
  throw new Error('usage: configure-zed.js SETTINGS_PATH FORMATTER_COMMAND');
}

const original = fs.existsSync(settingsPath) ? fs.readFileSync(settingsPath, 'utf8') : '{}';
let settings;
try {
  settings = JSON.parse(stripJsonc(original));
} catch (error) {
  throw new Error(`cannot parse ${settingsPath}: ${error.message}`);
}
if (!settings || Array.isArray(settings) || typeof settings !== 'object') {
  throw new Error(`${settingsPath} must contain a JSON object`);
}
if (!settings.languages || Array.isArray(settings.languages) || typeof settings.languages !== 'object') {
  settings.languages = {};
}
if (!settings.languages.SQL || Array.isArray(settings.languages.SQL) || typeof settings.languages.SQL !== 'object') {
  settings.languages.SQL = {};
}
settings.languages.SQL.format_on_save = 'on';
settings.languages.SQL.formatter = { external: { command: commandPath } };
fs.mkdirSync(path.dirname(settingsPath), { recursive: true });
fs.writeFileSync(settingsPath, `${JSON.stringify(settings, null, 2)}\n`, 'utf8');
