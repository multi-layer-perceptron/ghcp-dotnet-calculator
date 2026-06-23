const fs = require('fs');
const path = require('path');

// Narrow target list - absolute or repo-relative paths
const targets = [
  'programming/python/calculator-python-pycharm.md',
  'programming/python/calculator-python-vs2022.md',
  'programming/python/ghc-survey-python.md',
  'programming/python/completed/python-flask-to-do-list.md',
  'programming/java/pnd-calculator-java-intellij.md',
  'programming/typescript-html-css/workspace/src/calculator-typescript-vs2022.md',
  'programming/typescript-html-css/workspace/src/calculator-typescript-webstorm.md',
].map(p => path.join(process.cwd(), p));

function convertIndentedToFenced(text) {
  const lines = text.split(/\r?\n/);
  const out = [];
  let inIndented = false;
  let buffer = [];
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const isIndented = /^(\t| {4,})/.test(line);

    if (isIndented && !inIndented) {
      // start collecting indented block
      inIndented = true;
      buffer = [line.replace(/^(\t| {4})/, '')];
      continue;
    }

    if (isIndented && inIndented) {
      buffer.push(line.replace(/^(\t| {4})/, ''));
      continue;
    }

    if (!isIndented && inIndented) {
      // flush buffer as fenced block
      out.push('');
      out.push('```text');
      out.push(...buffer);
      out.push('```');
      out.push('');
      inIndented = false;
      buffer = [];
    }

    out.push(line);
  }

  if (inIndented && buffer.length) {
    out.push('');
    out.push('```text');
    out.push(...buffer);
    out.push('```');
    out.push('');
  }

  // Normalize multiple blank lines
  return out.join('\n').replace(/\n{3,}/g, '\n\n');
}

function run() {
  const patched = [];
  for (const f of targets) {
    try {
      if (!fs.existsSync(f)) {
        console.log('Missing:', f);
        continue;
      }
      const src = fs.readFileSync(f, 'utf8');
      const converted = convertIndentedToFenced(src);
      if (converted !== src) {
        fs.writeFileSync(f, converted, 'utf8');
        patched.push(f);
      }
    } catch (err) {
      console.error('Error processing', f, err.message);
    }
  }
  console.log('Patched files:');
  patched.forEach(p => console.log(p));
}

run();
