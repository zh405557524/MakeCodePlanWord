import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { mkdtempSync, mkdirSync, readFileSync, readdirSync, rmSync, writeFileSync, existsSync } from 'node:fs';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import test from 'node:test';

const workspace = fileURLToPath(new URL('../../', import.meta.url));
const reviewName = 'requirements-review.md';
const reportName = 'detection-feedback.md';
const oldReviewName = '3-简化版说明.md';
const oldReportName = '4-产品文档评审.md';

function run(script, ...args) {
  const result = spawnSync('/bin/bash', [path.join(workspace, 'scripts', script), ...args], {
    encoding: 'utf8',
    env: { ...process.env, TZ: 'America/Los_Angeles' },
  });
  if (result.error) throw result.error;
  assert.equal(result.status, 0, result.stderr || result.stdout);
  assert.equal(result.stderr, '', `${script} emitted unexpected diagnostics`);
  return result.stdout;
}

function fixture(t) {
  const root = mkdtempSync(path.join(tmpdir(), 'product-docs-test-'));
  t.after(() => rmSync(root, { recursive: true, force: true }));
  const project = path.join(root, '测试项目 with spaces');
  run('init-project.sh', project, '测试项目');
  return project;
}

function write(root, relative, content) {
  const file = path.join(root, relative);
  mkdirSync(path.dirname(file), { recursive: true });
  writeFileSync(file, content);
}

function snapshot(root) {
  const files = {};
  function walk(dir) {
    for (const entry of readdirSync(dir, { withFileTypes: true })) {
      const file = path.join(dir, entry.name);
      if (entry.isDirectory()) walk(file);
      else files[path.relative(root, file)] = readFileSync(file, 'utf8');
    }
  }
  walk(root);
  return files;
}

function assertFourDocs(project, version) {
  const root = path.join(project, version);
  const product = path.join(root, '01-产品');
  assert.deepEqual(readdirSync(product).sort(), [
    'detection-feedback.md', 'requirements-list.md', 'requirements-review.md', 'requirements.md',
  ]);
  assert.match(readFileSync(path.join(product, 'requirements.md'), 'utf8'), /只写本版增量/);
  const review = readFileSync(path.join(product, reviewName), 'utf8');
  const report = readFileSync(path.join(product, reportName), 'utf8');
  assert.equal([...review.matchAll(/^## \d+\./gm)].length, 11);
  assert.match(review, /所有页面各有一行/);
  assert.match(report, /当前结论 \| 未执行/);
  assert.match(report, /用户批准产品 \| 未确认/);
  assert.ok(!existsSync(path.join(product, oldReviewName)));
  assert.ok(!existsSync(path.join(product, oldReportName)));
  // Generated local navigation must resolve, including links copied from older versions.
  for (const [relative, text] of Object.entries(snapshot(root))) {
    const links = [...text.matchAll(/\]\(([^)]+)\)/g), ...text.matchAll(/^\s*\[[^\]]+\]:\s*(\S+)/gm)];
    for (const match of links) {
      const target = match[1].split('#')[0];
      if (!target || /^(?:[a-z]+:|\/)/i.test(target)) continue;
      assert.ok(existsSync(path.resolve(root, path.dirname(relative), target)), `${relative}: ${target}`);
    }
  }
}

test('first version has exactly four documents, a baseline reference and independent approval gates', (t) => {
  const project = fixture(t);
  run('new-version.sh', project, 'v1.0.0');
  assertFourDocs(project, 'v1.0.0');
  const before = snapshot(project);
  assert.throws(() => run('new-version.sh', project, 'v1.0.0'), /版本文件夹已存在/);
  assert.deepEqual(snapshot(project), before);
});

test('existing project references full baseline, copies only design and leaves sources unchanged', (t) => {
  const project = fixture(t);
  run('new-version.sh', project, 'v1.0.0');
  write(project, '当前产品文档/00-总纲.md', '# Current baseline\n\n> **文档定位**：v1.0.0 线上产品\n\nCURRENT_RULE\n');
  write(project, 'v1.0.0/02-设计/设计说明.md', '# Existing design\n\nDESIGN_RULE\n');
  const current = snapshot(path.join(project, '当前产品文档'));
  const previous = snapshot(path.join(project, 'v1.0.0'));
  run('new-version.sh', project, 'v1.1.0');
  assertFourDocs(project, 'v1.1.0');
  const requirements = readFileSync(path.join(project, 'v1.1.0/01-产品/requirements.md'), 'utf8');
  assert.ok(requirements.includes('../../当前产品文档/00-总纲.md'));
  assert.match(requirements, /v1\.0\.0/);
  assert.doesNotMatch(requirements, /CURRENT_RULE/);
  assert.match(readFileSync(path.join(project, 'v1.1.0/02-设计/设计说明.md'), 'utf8'), /DESIGN_RULE/);
  assert.deepEqual(snapshot(path.join(project, '当前产品文档')), current);
  assert.deepEqual(snapshot(path.join(project, 'v1.0.0')), previous);
});

test('explicit legacy source rewrites only local navigation in copied documents', (t) => {
  const project = fixture(t);
  run('new-version.sh', project, 'v1.0.0');
  run('new-version.sh', project, 'v1.1.0');
  write(project, '当前产品文档/00-总纲.md', '# Current\n\n> **文档定位**：v1.1.0 线上产品\n\nCURRENT_RULE\n');
  write(project, `v1.0.0/01-产品/${oldReviewName}`, '# Historical review\n');
  write(project, `v1.0.0/01-产品/${oldReportName}`, '# Historical report\n');
  write(project, 'v1.0.0/01-产品/2-v1.0.0产品文档/00-总纲.md', '# Old product\n\nEXPLICIT_SOURCE\n');
  write(project, 'v1.0.0/03-技术规划/nested/guide.md', [
    '# Copied navigation', 'EXPLICIT_DESIGN_SOURCE',
    `[local](../../01-产品/${oldReviewName})`,
    `[report](./../../01-产品/${oldReportName}#用户意见)`,
    '[latest-review](../../01-产品/3-产品评审版.md)',
    '[latest-report](../../01-产品/4-产品文档检测报告.md)',
    '[analysis](../../01-产品/1-需求分析.md#原分析)',
    '[changes](../../01-产品/改动清单.md)',
    '[product](../../01-产品/2-v1.0.0产品文档/00-总纲.md#旧标题)',
    '[module](../../01-产品/2-v1.0.0产品文档/02-账号与合规.md#规则)',
    '[reference]: ../../01-产品/改动清单.md',
    `[archive](../../../v1.0.0/01-产品/${oldReviewName})`,
    `[external](https://example.com/${oldReviewName})`, '',
  ].join('\n'));
  const current = snapshot(path.join(project, '当前产品文档'));
  const previous = snapshot(path.join(project, 'v1.0.0'));
  const latest = snapshot(path.join(project, 'v1.1.0'));
  run('new-version.sh', project, 'v1.2.0', '--from', 'v1.0.0');
  assertFourDocs(project, 'v1.2.0');
  const product = readFileSync(path.join(project, 'v1.2.0/01-产品/requirements.md'), 'utf8');
  assert.doesNotMatch(product, /EXPLICIT_SOURCE|CURRENT_RULE/);
  assert.ok(product.includes('（v1.1.0）'));
  assert.ok(product.includes('参考版本：v1.0.0'));
  const guide = readFileSync(path.join(project, 'v1.2.0/03-技术规划/nested/guide.md'), 'utf8');
  for (const expected of [
    'EXPLICIT_DESIGN_SOURCE',
    `[local](../../01-产品/${reviewName})`,
    `[report](./../../01-产品/${reportName}#用户意见)`,
    '[latest-review](../../01-产品/requirements-review.md)',
    '[latest-report](../../01-产品/detection-feedback.md)',
    '[analysis](../../01-产品/requirements-list.md)',
    '[changes](../../01-产品/requirements-list.md)',
    '[product](../../01-产品/requirements.md)',
    '[module](../../01-产品/requirements.md)',
    '[reference]: ../../01-产品/requirements-list.md',
    `[archive](../../../v1.0.0/01-产品/${oldReviewName})`,
    `[external](https://example.com/${oldReviewName})`,
  ]) assert.ok(guide.includes(expected), expected);
  assert.deepEqual(snapshot(path.join(project, '当前产品文档')), current);
  assert.deepEqual(snapshot(path.join(project, 'v1.0.0')), previous);
  assert.deepEqual(snapshot(path.join(project, 'v1.1.0')), latest);
});

test('patch still produces only its repair sheet and leaves prior versions unchanged', (t) => {
  const project = fixture(t);
  run('new-version.sh', project, 'v1.0.0');
  const previous = snapshot(path.join(project, 'v1.0.0'));
  run('new-version.sh', project, 'v1.0.1', '--patch');
  assert.deepEqual(readdirSync(path.join(project, 'v1.0.1')), ['修复单.md']);
  assert.deepEqual(snapshot(path.join(project, 'v1.0.0')), previous);
});

test('missing explicit source fails without creating a partial version', (t) => {
  const project = fixture(t);
  const before = snapshot(project);
  assert.throws(() => run('new-version.sh', project, 'v2.0.0', '--from', 'v1.0.0'), /找不到来源版本/);
  assert.deepEqual(snapshot(project), before);
});

test('delta archive is refused before any mutation even if an old full copy remains', (t) => {
  const project = fixture(t);
  run('new-version.sh', project, 'v1.0.0');
  write(project, '当前产品文档/00-总纲.md', '# Baseline\n\nKEEP_UNCHANGED_RULES\n');
  write(project, 'v1.0.0/01-产品/2-v1.0.0产品文档/00-总纲.md', '# Stale full copy\n');
  write(project, '.当前产品文档.old/keep.md', 'Existing unrelated backup\n');
  const before = snapshot(project);
  assert.throws(() => run('update-current-doc.sh', project, 'v1.0.0'), /四文档增量结构/);
  assert.deepEqual(snapshot(project), before);
});

test('legacy full-format migration still works in a temporary workspace', (t) => {
  const project = fixture(t);
  write(project, 'v1.0.0/01-产品/2-v1.0.0产品文档/00-总纲.md',
    '# Legacy full definition\n\n> **文档定位**：v1.0.0 全量\n\nFULL_RULE\n');
  const source = snapshot(path.join(project, 'v1.0.0'));
  run('update-current-doc.sh', project, 'v1.0.0');
  assert.match(readFileSync(path.join(project, '当前产品文档/00-总纲.md'), 'utf8'), /FULL_RULE/);
  assert.deepEqual(snapshot(path.join(project, 'v1.0.0')), source);
});
