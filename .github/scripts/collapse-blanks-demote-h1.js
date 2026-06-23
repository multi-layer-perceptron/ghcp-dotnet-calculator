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
    let before = txt;
    // 1) Collapse 3+ blank lines into a single blank line (i.e., two newlines)
    txt = txt.replace(/\n{3,}/g, '\n\n');

    // 2) Demote H1s after the first to H2 to avoid multiple top-level headings
    const lines = txt.split('\n');
    let seenH1 = false;
    for (let i = 0; i < lines.length; i++) {
      if (/^#\s+/.test(lines[i])) {
        if (!seenH1) {
          seenH1 = true;
        } else {
          // demote to H2 if it's a top-level heading
          lines[i] = lines[i].replace(/^#\s+/, '## ');
        }
      }
    }
    txt = lines.join('\n');

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
