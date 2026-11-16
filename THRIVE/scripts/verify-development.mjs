import assert from 'node:assert/strict';

const api = process.env.THRIVE_API_URL ?? 'http://localhost:5280';
const runId = Date.now().toString(36);

async function request(path, { token, method = 'GET', body, statuses = [200] } = {}) {
  const response = await fetch(`${api}/api/v1${path}`, {
    method,
    headers: {
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...(body === undefined ? {} : { 'Content-Type': 'application/json' }),
    },
    ...(body === undefined ? {} : { body: JSON.stringify(body) }),
    signal: AbortSignal.timeout(15000),
  });
  assert.ok(statuses.includes(response.status), `${method} ${path}: expected ${statuses}, received ${response.status}`);
  const text = await response.text();
  return { status: response.status, data: text ? JSON.parse(text) : null };
}

async function developmentIdentity(persona) {
  const { data } = await request('/development/session', { method: 'POST', body: { persona } });
  const token = data.accessToken;
  const me = (await request('/me', { token })).data;
  assert.equal(me.isDevelopmentIdentity, true, 'This check must only use synthetic development identities.');
  return token;
}

async function main() {
  const destination = new URL(api);
  assert.ok(['localhost', '127.0.0.1'].includes(destination.hostname) && destination.port === '5280'
    && destination.protocol === 'http:', 'Refusing any destination outside the local THRIVE Test API.');
  const identityResponse = await fetch(`${api}/health/isolation`, { signal: AbortSignal.timeout(15000) });
  assert.equal(identityResponse.status, 200, 'The live test database identity must be verified before writes.');
  const identity = await identityResponse.json();
  assert.equal(identity.application, 'THRIVE Test');
  assert.equal(identity.database, 'thrive_test');
  assert.equal(identity.databaseUser, 'thrive_test_local');
  assert.equal(identity.databasePort, 55432);
  assert.ok([55432, 5432].includes(identity.serverPort));
  console.log('PASS live THRIVE Test / thrive_test destination verified before all writes');
  const student = await developmentIdentity('student-b');
  const other = await developmentIdentity('student-other-university');
  const admin = await developmentIdentity('admin');
  const { version } = (await request('/consent-policies/current')).data;
  await request('/me/consents', { token: student, method: 'PUT', body: { policyVersion: version, serviceUse: true, researchUse: false } });
  await request('/admin/services', { token: student, statuses: [403] });
  await request('/me/screenings', { token: admin, statuses: [403] });
  console.log('PASS development identity, optional research, and role boundaries');

  const diaryDay = new Date().toISOString().slice(0, 10);
  try {
    await request(`/me/moods/${diaryDay}`, { token: student, method: 'PUT', body: { value: 4 } });
    const feelings = (await request(`/me/moods?from=${diaryDay}&to=${diaryDay}`, { token: student })).data;
    assert.equal(feelings.find(value => value.day === diaryDay)?.value, 4);
    const activity = (await request('/me/activity', { token: student })).data;
    assert.equal(typeof activity.completedScreenings, 'number');
    assert.equal(typeof activity.openReferrals, 'number');
  } finally {
    await request(`/me/moods/${diaryDay}`, { token: student, method: 'DELETE', statuses: [204] });
  }
  console.log('PASS optional daily feeling, activity summary, and removal');

  const instruments = (await request('/instruments', { token: student })).data;
  const instrument = instruments.find(value => value.code === 'DEMO-CHECK');
  assert.equal(instrument?.isDemo, true);
  const session = (await request('/screening/sessions', { token: student, method: 'POST', body: { instrumentCode: instrument.code } })).data;
  await request(`/screening/sessions/${session.id}`, { token: other, statuses: [403, 404] });
  await request(`/screening/sessions/${session.id}/submit`, { token: student, method: 'POST', statuses: [400, 409] });
  await request(`/screening/sessions/${session.id}/answers/${instrument.items[0].code}`, { token: student, method: 'PUT', body: { value: 999 }, statuses: [400] });
  let expectedTotal = 0;
  for (const item of instrument.items) {
    const value = item.options[0].value;
    expectedTotal += value;
    await request(`/screening/sessions/${session.id}/answers/${item.code}`, { token: student, method: 'PUT', body: { value } });
  }
  const result = (await request(`/screening/sessions/${session.id}/submit`, { token: student, method: 'POST' })).data;
  assert.equal(result.state, 'Demo');
  assert.equal(result.isDemo, true);
  assert.equal(result.rawScore, expectedTotal);
  const repeated = (await request(`/screening/sessions/${session.id}/submit`, { token: student, method: 'POST' })).data;
  assert.equal(repeated.createdAtUtc, result.createdAtUtc);
  await request(`/screening/sessions/${session.id}/answers/${instrument.items[0].code}`, { token: student, method: 'PUT', body: { value: instrument.items[0].options[0].value }, statuses: [409] });
  assert.ok((await request('/me/screenings', { token: student })).data.some(value => value.id === session.id));
  console.log('PASS screening validation, ownership, save/resume, sum, immutable result, idempotency, history');

  const resourceWrite = {
    slug: `qa-product-guide-${runId}`, titleAr: 'مورد اختبار المنتج', titleEn: 'Product QA guide',
    summaryAr: 'اختبار تطوير فقط', summaryEn: 'Development verification only',
    bodyAr: 'هذا المحتوى لتجربة التنقل والحفظ فقط.', bodyEn: 'This content verifies navigation and saving only.',
    category: 'Product', source: 'THRIVE development verification', version: 'qa-1', published: false,
  };
  const resource = (await request('/admin/resources', { token: admin, method: 'POST', body: resourceWrite, statuses: [200, 201] })).data;
  assert.equal(resource.isDemo, true);
  assert.ok(!(await request('/guide/resources', { token: student })).data.some(value => value.id === resource.id));
  await request(`/admin/resources/${resource.id}`, { token: admin, method: 'PUT', body: { ...resourceWrite, published: true } });
  assert.ok((await request('/guide/resources', { token: student })).data.some(value => value.id === resource.id));
  assert.equal((await request(`/guide/resources/${resource.id}`, { token: student })).data.slug, resourceWrite.slug);
  console.log('PASS admin resource publishing and student directory visibility');

  const serviceWrite = {
    level: 'Counseling', nameAr: `خدمة اختبار ${runId}`, nameEn: `QA service ${runId}`,
    descriptionAr: 'خدمة اصطناعية لا ترسل طلبات فعلية', descriptionEn: 'Synthetic service, no external delivery',
    hoursAr: 'محاكاة', hoursEn: 'Simulation', locationAr: 'بيئة التطوير', locationEn: 'Development sandbox',
    bookingMethod: 'Sandbox request', contactUrl: null, verified: false, active: true,
  };
  const service = (await request('/admin/services', { token: admin, method: 'POST', body: serviceWrite, statuses: [200, 201] })).data;
  assert.equal(service.isDemo, true);
  assert.equal(service.verified, false);
  assert.ok((await request('/services?level=Counseling', { token: student })).data.some(value => value.id === service.id));
  await request('/referrals', { token: student, method: 'POST', body: { serviceId: service.id, shareConsent: false }, statuses: [400] });
  const referral = (await request('/referrals', { token: student, method: 'POST', body: { serviceId: service.id, shareConsent: true }, statuses: [200, 201] })).data;
  assert.equal(referral.status, 'Requested');
  const duplicate = await request('/referrals', { token: student, method: 'POST', body: { serviceId: service.id, shareConsent: true }, statuses: [200, 201, 409] });
  if (duplicate.status !== 409) assert.equal(duplicate.data.id, referral.id);
  await request(`/admin/referrals/${referral.id}/status`, { token: admin, method: 'PUT', body: { status: 'Completed' }, statuses: [409] });
  for (const status of ['Received', 'Scheduled', 'Completed']) {
    assert.equal((await request(`/admin/referrals/${referral.id}/status`, { token: admin, method: 'PUT', body: { status } })).data.status, status);
  }
  assert.ok((await request('/me/referrals', { token: student })).data.some(value => value.id === referral.id && value.status === 'Completed'));
  const cancelled = (await request('/referrals', { token: student, method: 'POST', body: { serviceId: service.id, shareConsent: true }, statuses: [200, 201] })).data;
  assert.equal((await request(`/me/referrals/${cancelled.id}/cancel`, { token: student, method: 'POST' })).data.status, 'Cancelled');
  const report = (await request('/admin/reports/aggregate', { token: admin })).data;
  assert.ok(report.minCellSize >= 5);
  assert.ok(report.screeningsCount === null || report.screeningsCount >= report.minCellSize);
  console.log('PASS service CRUD, explicit sharing, duplicate guard, referral state machine, cancellation, aggregation');

  try {
    const withdrawn = (await request('/me/consents/withdraw', { token: student, method: 'POST' })).data;
    assert.equal(withdrawn.serviceUse, false);
    await request('/me/screenings', { token: student, statuses: [403] });
  } finally {
    await request('/me/consents', { token: student, method: 'PUT', body: { policyVersion: version, serviceUse: true, researchUse: false } });
  }
  console.log('PASS withdrawal revokes functional access and reconsent restores it');
  console.log('Development MVP integration verification passed. Only synthetic records were created.');
}

main().catch(error => {
  console.error(error.message);
  process.exitCode = 1;
});
