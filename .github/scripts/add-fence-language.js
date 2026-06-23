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
  // replace lines that are exactly ``` (optionally spaces) followed by newline, not already with language
  const newContent = content.replace(/^```[ \t]*\r?$/gm, '```text');
  if (newContent !== content) {
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
