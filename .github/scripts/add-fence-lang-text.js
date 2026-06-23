#!/usr/bin/env node
const fs = require('fs');
const path = require('path');

const root = process.cwd();

function walk(dir, cb) {
  const list = fs.readdirSync(dir, { withFileTypes: true });
  for (const d of list) {
    const full = path.join(dir, d.name);
    if (d.isDirectory()) {
      if (d.name === 'node_modules' || d.name === '.git') continue;
      walk(full, cb);
    } else {
      cb(full);
    }
  }
}

function isMarkdown(file) {
  return file.endsWith('.md');
}

const patched = [];

walk(root, (file) => {
  if (!isMarkdown(file)) return;
  if (file.includes(path.join('dev', 'Lib')) || file.includes('site-packages')) return;
  try {
    let txt = fs.readFileSync(file, 'utf8');
    const before = txt;
    // Replace lines that are exactly ``` (possibly with trailing spaces) with ```text
    txt = txt.replace(/^```\s*$/gm, '```text');
    if (txt !== before) {
      fs.writeFileSync(file, txt, 'utf8');
      patched.push(file);
    }
  } catch (e) {}
});

if (patched.length) {
  console.log('Patched files:');
  patched.forEach(f => console.log(f));
  process.exit(0);
} else {
  console.log('No files changed');
  process.exit(0);
}
