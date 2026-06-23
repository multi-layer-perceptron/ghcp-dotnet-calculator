const fs = require('fs');
const path = require('path');

const mapping = {
  'databases/rdbms/workspace/sql/prd-azure-sql-examples.md': 'sql',
  'genai/11-voice-live-agent-web.md': 'bash',
  'genai/prd-11-voice-live-agent-web.md': 'bash',
  'programming/javascript-html-css/workspace/calculator/README.md': 'js',
  'programming/node/workspace/calculator/README.md': 'js',
  'programming/python/calculator-python-pycharm.md': 'python',
  'programming/python/calculator-python-vs2022.md': 'python',
  'programming/python/ghc-survey-python.md': 'python',
  'programming/python/completed/python-flask-to-do-list.md': 'python',
  'programming/java/calculator-java-vscode-insders.md': 'java',
  'programming/java/ghc-survey-java.md': 'java',
  'programming/java/pnd-calculator-java-intellij.md': 'java',
  'programming/typescript-html-css/workspace/src/calculator-typescript-vs2022.md': 'ts',
  'programming/typescript-html-css/workspace/src/calculator-typescript-webstorm.md': 'ts',
  'programming/typescript-react/workspace/calculator-typescript/README.md': 'ts',
  'programming/dotnet/csharp/completed/calculator-xunit-testing/CALCULATORWEB_SOLUTION.md': 'powershell',
  'programming/dotnet/csharp/completed/calculator-xunit-testing/SOLUTION_CREATION_COMPLETE.md': 'powershell',
  'programming/javascript-html-css/prd-codeql-scenarios.md': 'bash'
};

function ensureDir(f) {
  const d = path.dirname(f);
  fs.mkdirSync(d, { recursive: true });
}

function convertIndentedToFencedWithLang(text, lang) {
  const lines = text.split(/\r?\n/);
  const out = [];
  let inIndented = false;
  let buffer = [];
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const isIndented = /^(\t| {4,})/.test(line);
    if (isIndented && !inIndented) {
      inIndented = true;
      buffer = [line.replace(/^(\t| {4})/, '')];
      continue;
    }
    if (isIndented && inIndented) {
      buffer.push(line.replace(/^(\t| {4})/, ''));
      continue;
    }
    if (!isIndented && inIndented) {
      out.push('');
      out.push('```' + lang);
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
    out.push('```' + lang);
    out.push(...buffer);
    out.push('```');
    out.push('');
  }
  return out.join('\n');
}

function setDefaultFenceLang(text, lang) {
  // Replace fences that are just ``` or ```text with ```lang
  return text.replace(/(^|\n)```(?:text)?\n/g, `$1\`\\\`${lang}\n`);
}

function transform(content, lang) {
  let t = convertIndentedToFencedWithLang(content, lang);
  t = setDefaultFenceLang(t, lang);
  // collapse 3+ blank lines
  t = t.replace(/\n{3,}/g, '\n\n');
  // ensure single trailing newline
  t = t.replace(/\s+$/g, '\n');
  return t;
}

function run() {
  const repoRoot = process.cwd();
  const proposedRoot = path.join(repoRoot, '.github', 'proposed');
  const created = [];
  for (const rel in mapping) {
    const src = path.join(repoRoot, rel);
    if (!fs.existsSync(src)) {
      console.log('SKIP (missing):', rel);
      continue;
    }
    const lang = mapping[rel] || 'text';
    const orig = fs.readFileSync(src, 'utf8');
    const changed = transform(orig, lang);
    const outPath = path.join(proposedRoot, rel);
    ensureDir(outPath);
    fs.writeFileSync(outPath, changed, 'utf8');
    created.push(path.relative(repoRoot, outPath));
  }
  console.log('Proposed files created under .github/proposed:');
  created.forEach(f => console.log(f));
}

run();
