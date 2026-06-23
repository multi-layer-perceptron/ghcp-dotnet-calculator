const fs = require('fs');
const path = require('path');

function walk(dir) {
  let results = [];
  const list = fs.readdirSync(dir);
  list.forEach(function(file) {
    file = path.resolve(dir, file);
    const stat = fs.statSync(file);
    if (stat && stat.isDirectory()) {
      if (file.includes('node_modules') || file.includes('.git')) return;
      results = results.concat(walk(file));
    } else {
      if (file.endsWith('.md')) results.push(file);
    }
  });
  return results;
}

const files = walk(process.cwd());
let patched = [];

files.forEach(f => {
  let content = fs.readFileSync(f, 'utf8');
  let orig = content;

  // 1) Normalize ordered list prefixes: replace leading digits with 1.
  content = content.replace(/^(\s*)\d+\.(\s+)/gm, '$11.$2');

  // 2) Ensure blank lines before and after fenced code blocks
  const lines = content.split(/\r?\n/);
  let out = [];
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    if (/^```/.test(line)) {
      // ensure blank line before
      if (out.length > 0 && out[out.length-1].trim() !== '') {
        out.push('');
      }
      // push opening fence
      out.push(line);
      // copy until closing fence
      i++;
      while (i < lines.length && !/^```/.test(lines[i])) {
        out.push(lines[i]);
        i++;
      }
      if (i < lines.length) {
        // push closing fence
        out.push(lines[i]);
      } else {
        // file ended without closing fence - nothing special
      }
      // ensure blank line after closing fence (if next original line exists and not blank)
      const nextOrig = (i+1 < lines.length) ? lines[i+1] : null;
      if (nextOrig !== null && nextOrig.trim() !== '') {
        out.push('');
      }
    } else {
      out.push(line);
    }
  }

  const newContent = out.join('\n');
  if (newContent !== orig) {
    fs.writeFileSync(f, newContent, 'utf8');
    patched.push(f);
  }
});

if (patched.length === 0) {
  console.log('No files patched.');
} else {
  console.log('Patched files:');
  patched.forEach(p => console.log(p));
}
