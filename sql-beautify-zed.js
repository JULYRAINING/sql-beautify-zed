#!/usr/bin/env node
'use strict';

const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

const formatterPath = path.join(__dirname, 'vendor', 'vkbeautify-0.99.1', 'index.js');
const expectedSha1 = 'dde215b5ffe988d7e54e383d27e849ca07497412';

function fail(message) {
  process.stderr.write(`sql-beautify-zed: ${message}\n`);
  process.exitCode = 1;
}

try {
  const actualSha1 = crypto.createHash('sha1').update(fs.readFileSync(formatterPath)).digest('hex');
  if (actualSha1 !== expectedSha1) {
    throw new Error(`formatter integrity check failed (${actualSha1})`);
  }

  const input = fs.readFileSync(0, 'utf8');
  const formatter = require(formatterPath);
  const originalLog = console.log;
  let output;
  try {
    // The bundled formatter uses console.log internally. Zed expects stdout
    // to contain the formatted document only.
    console.log = () => {};
    // Retain the extension's behavior, but align AS up to column 400.
    output = formatter.sql(input, true, false, false, 400);
  } finally {
    console.log = originalLog;
  }
  process.stdout.write(output);
} catch (error) {
  fail(error.message);
}
