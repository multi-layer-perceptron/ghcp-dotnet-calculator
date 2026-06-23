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

  // 1) Ensure blank lines around fenced code blocks (MD031)
  // Add a blank line before a fence if previous line is not blank
  content = content.replace(/([^\n])\n(```[\s\S]*?```)/g, (m, a, b) => {
    changed = true;
    return a + '\n\n' + b;
  });
  // Add a blank line after a closing fence if next line is not blank
  content = content.replace(/(```[\s\S]*?```)([^\n\s])/g, (m, a, b) => {
    changed = true;
    return a + '\n\n' + b;
  });

  // 2) Normalize ordered list prefixes to '1.' for simple lists (MD029)
  // Only when lines start with a number and dot and a space
  content = content.replace(/^\s*\d+\.\s+/gm, (m) => {
    changed = true;
    return m.replace(/\d+\./, '1.');
  });

  // 3) Conservative emphasis -> heading conversion
  // Convert lines that are entirely wrapped in '**' or '__' with no other markup to headings
  content = content.replace(/^\s*\*\*(.+?)\*\*\s*$/gm, (m, p1) => {
    // avoid converting if the content contains other markdown markers
    if (/[`\[\]\*_#<>]/.test(p1)) return m;
    changed = true;
    return '# ' + p1.trim();
  });

  return { content, changed };
}

const patched = [];

walk(root, (file) => {
  if (!isMarkdown(file)) return;
  // skip license files in site-packages or dist-info
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
    // ignore binary or unreadable files
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
