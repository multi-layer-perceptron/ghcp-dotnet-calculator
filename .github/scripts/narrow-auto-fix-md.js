const fs = require('fs');
const path = require('path');

const EXCLUDE_DIRS = [
  'node_modules',
  '.git',
  'programming/python/workspace/genai/dev',
  'programming/python/workspace/genai',
  'genai/workspace/11-voice-live-agent/python/src',
];

function walk(dir, fileList = []) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const e of entries) {
    const full = path.join(dir, e.name);
    if (e.isDirectory()) {
      if (EXCLUDE_DIRS.some(ex => full.includes(ex))) continue;
      walk(full, fileList);
    } else if (e.isFile() && full.endsWith('.md')) {
      fileList.push(full);
    }
  }
  return fileList;
}

function transform(content) {
  // 1) Add default fence language `text` when fence has no language
  content = content.replace(/(^|\n)```\n/g, '$1```text\n');

  // 2) Ensure blank lines before and after fenced code blocks
  content = content.replace(/([^\n])\n```/g, '$1\n\n```');
  content = content.replace(/```([^\n])/g, '```\n\n$1');

  // 3) Wrap bare http(s) URLs in angle brackets (simple heuristic)
  content = content.replace(/(^|[^<\(\"])(https?:\/\/[^\s)\]\[]>]+)/g, '$1<$2>');

  // 4) Collapse 3+ blank lines to a single blank line
  content = content.replace(/\n{3,}/g, '\n\n');

  // 5) Ensure single trailing newline
  content = content.replace(/\s+$/g, '\n');

  return content;
}

function run() {
  const root = process.cwd();
  const files = walk(root);
  const patched = [];
  for (const f of files) {
    let txt = fs.readFileSync(f, 'utf8');
    const out = transform(txt);
    if (out !== txt) {
      fs.writeFileSync(f, out, 'utf8');
      patched.push(f);
    }
  }
  console.log('Patched files:');
  patched.forEach(p => console.log(p));
}

run();
