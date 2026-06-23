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

function titleFromPath(file) {
  const name = path.basename(file, '.md');
  // replace dashes/underscores with spaces and title-case
  return name.replace(/[-_]+/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase());
}

function applyFixes(file, content) {
  let changed = false;

  // 1) Insert H1 if file has no '# ' heading anywhere (MD041)
  if (!/^[ \t]*#\s+/m.test(content)) {
    const title = titleFromPath(file);
    content = '# ' + title + '\n\n' + content;
    changed = true;
  }

  // 2) Wrap bare http(s) URLs in angle brackets to avoid MD034 (bare URLs)
  // Regex matches http(s)://... up to whitespace or )]
  content = content.replace(/(^|\s)(https?:\/\/[^\s)\]]+)/g, (m, pre, url) => {
    changed = true;
    return pre + '<' + url + '>';
  });

  // 3) Ensure a single blank line after headings (already handled partly earlier)
  content = content.replace(/^(#{1,6}[^\n]+)\n(?!\n)/gm, (m, h) => {
    changed = true;
    return h + '\n\n';
  });

  return { content, changed };
}

const patched = [];

walk(root, (file) => {
  if (!isMarkdown(file)) return;
  if (file.includes(path.join('dev', 'Lib')) || file.includes('site-packages')) return;
  try {
    let txt = fs.readFileSync(file, 'utf8');
    const res = applyFixes(file, txt);
    if (res.changed && res.content !== txt) {
      fs.writeFileSync(file, res.content, 'utf8');
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
