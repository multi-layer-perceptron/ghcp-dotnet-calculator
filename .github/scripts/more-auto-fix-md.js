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

function applyFixes(content) {
  let changed = false;

  // 1) Ensure blank line before and after headings (MD022)
  // Add blank line before a heading if previous line is not blank
  content = content.replace(/([^\n])\n(#{1,6}\s.+)/g, (m, a, b) => {
    changed = true;
    return a + '\n\n' + b;
  });
  // Add blank line after a heading if next line is not blank
  content = content.replace(/(#{1,6}\s.+)\n([^\n\s#`\-\*\+>\[])/g, (m, a, b) => {
    changed = true;
    return a + '\n\n' + b;
  });

  // 2) Ensure blank lines around lists (MD032)
  // Add blank line before top-level list marker if previous line not blank
  content = content.replace(/([^\n])\n(\s{0,0}[-\*\+]\s+)/g, (m, a, b) => {
    changed = true;
    return a + '\n\n' + b;
  });
  // Add blank line after end of list if following line is not blank
  content = content.replace(/(\n[-\*\+]\s.+(?:\n[-\*\+]\s.+)*?)\n([^\n\s#`\-\*\+>\[])/g, (m, a, b) => {
    changed = true;
    return a + '\n\n' + b;
  });

  // 3) Normalize top-level unordered list markers '*' to '-' (MD004)
  // Only convert lines that start with '*' and have no leading spaces (top-level)
  content = content.replace(/^\*\s+/gm, (m) => {
    changed = true;
    return m.replace(/^\*/, '-');
  });

  // 4) Remove trailing colon from headings where present (MD026)
  content = content.replace(/^(#{1,6}\s+.+?):\s*$/gm, (m, p1) => {
    changed = true;
    return p1;
  });

  return { content, changed };
}

const patched = [];

walk(root, (file) => {
  if (!isMarkdown(file)) return;
  // skip vendor/license and site-packages
  if (file.includes(path.join('dev', 'Lib')) || file.includes('site-packages')) return;
  try {
    let txt = fs.readFileSync(file, 'utf8');
    const before = txt;
    const res = applyFixes(txt);
    if (res.changed && res.content !== before) {
      fs.writeFileSync(file, res.content, 'utf8');
      patched.push(file);
    }
  } catch (e) {
    // ignore unreadable files
  }
});

if (patched.length) {
  console.log('Patched files:');
  patched.forEach((f) => console.log(f));
  process.exit(0);
} else {
  console.log('No files changed');
  process.exit(0);
}
