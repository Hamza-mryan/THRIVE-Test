import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const root = fileURLToPath(new URL('../', import.meta.url));
const read = (file) => readFileSync(path.join(root, file), 'utf8');
const json = (file) => JSON.parse(read(file));
const checks = [
  ['Android installed identity', () => {
    assert.match(read('apps/student-mobile/android/app/build.gradle.kts'), /applicationId = "edu\.thrive\.thrive_student\.test"/);
    assert.match(read('apps/student-mobile/android/app/src/main/AndroidManifest.xml'), /android:label="THRIVE Test"/);
  }],
  ['iOS installed identity in all configurations', () => {
    const ids = [...read('apps/student-mobile/ios/Runner.xcodeproj/project.pbxproj').matchAll(/PRODUCT_BUNDLE_IDENTIFIER = ([^;]+);/g)].map(x => x[1]);
    assert.equal(ids.length, 6);
    assert.ok(ids.every(id => ['edu.thrive.thriveStudent.test', 'edu.thrive.thriveStudent.test.RunnerTests'].includes(id)));
    assert.match(read('apps/student-mobile/ios/Runner/Info.plist'), /<key>CFBundleDisplayName<\/key>\s*<string>THRIVE Test<\/string>/);
  }],
  ['Web app and public cache identity', () => {
    const manifest = json('apps/student-mobile/web/manifest.json');
    assert.equal(manifest.name, 'THRIVE Test');
    assert.equal(manifest.short_name, 'THRIVE Test');
    assert.equal(manifest.id, '/thrive-test');
    assert.match(read('apps/student-mobile/lib/features/guide/data/guide_repository.dart'), /'thrive-test\.public-guides\.v1'/);
    assert.match(read('apps/student-mobile/lib/main.dart'), /http:\/\/localhost:5280/);
  }],
  ['Dedicated frontend/backend ports', () => {
    assert.equal(json('apps/university-admin/proxy.conf.json')['/api'].target, 'http://localhost:5280');
    assert.equal(json('apps/university-admin/angular.json').projects['thrive-university-admin'].architect.serve.options.port, 4300);
    assert.equal(json('services/backend/src/Thrive.Api/Properties/launchSettings.json').profiles.local.applicationUrl, 'http://localhost:5280');
    assert.match(read('scripts/start-student.ps1'), /--web-port 5400/);
    assert.match(read('services/backend/src/Thrive.Api/Program.cs'), /http:\/\/localhost:5400/);
    assert.doesNotMatch(read('services/backend/src/Thrive.Api/Program.cs'), /localhost:(5300|4200)/);
  }],
  ['Database guards and new resource names', () => {
    assert.match(read('scripts/lib/LocalEnvironment.ps1'), /function Assert-ThriveTestDatabase/);
    assert.match(read('scripts/start-backend.ps1'), /Assert-ThriveTestDatabase/);
    assert.match(read('services/backend/src/Thrive.Api/Program.cs'), /TestEnvironment\.RequireDatabase/);
    assert.match(read('infrastructure/local/compose.yaml'), /55432:5432/);
    assert.doesNotMatch(read('scripts/start-database.ps1'), /postgresql-thrive-data/);
    assert.doesNotMatch(read('scripts/initialize-local.ps1'), /'POSTGRES_DB=thrive_development'/);
  }],
  ['Lifecycle records belong to this instance', () => {
    assert.match(read('scripts/start-project.ps1'), /test-processes\.json/);
    assert.match(read('scripts/stop-project.ps1'), /Assert-ThriveTestProcessRecord/);
    assert.doesNotMatch(read('scripts/stop-project.ps1'), /development-processes\.json/);
    assert.doesNotMatch(read('scripts/lib/FlutterEnvironment.ps1'), /'student-mobile-workspace'/);
    assert.doesNotMatch(read('scripts/build-android-debug.ps1'), /'student-android-build-workspace'/);
  }],
  ['Integration writer proves the live destination first', () => {
    const script = read('scripts/verify-development.mjs');
    assert.match(script, /health\/isolation/);
    assert.match(script, /thrive_test/);
    assert.doesNotMatch(script, /localhost:5180/);
  }],
];
let failed = 0;
for (const [name, verify] of checks) {
  try { verify(); console.log(`PASS ${name}`); }
  catch { failed++; console.error(`FAIL ${name}`); }
}
console.log(`${checks.length - failed}/${checks.length} isolation checks passed. No services or databases were modified.`);
process.exitCode = failed ? 1 : 0;
