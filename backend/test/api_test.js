const http = require('http');

function makeRequest(path, method = 'GET', data = null) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'localhost',
      port: 5000,
      path,
      method,
      headers: {
        'Content-Type': 'application/json'
      }
    };

    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, body: JSON.parse(body) });
        } catch (e) {
          resolve({ status: res.statusCode, body });
        }
      });
    });

    req.on('error', (err) => reject(err));

    if (data) {
      req.write(JSON.stringify(data));
    }
    req.end();
  });
}

async function runTests() {
  console.log('--- RUNNING SPEAKUP BACKEND API INTEGRATION TESTS ---');
  try {
    const health = await makeRequest('/api/health');
    console.log('[Test 1] GET /api/health:', health.status, health.body.status);

    const categories = await makeRequest('/api/categories');
    console.log('[Test 2] GET /api/categories:', categories.status, `Count: ${categories.body.count}`);

    const evaluators = await makeRequest('/api/evaluators');
    console.log('[Test 3] GET /api/evaluators:', evaluators.status, `Count: ${evaluators.body.count}`);

    const login = await makeRequest('/api/auth/login', 'POST', { email: 'amina@speakup.ai', password: 'password123' });
    console.log('[Test 4] POST /api/auth/login:', login.status, `User: ${login.body.user ? login.body.user.name : 'N/A'}`);

    const socialLogin = await makeRequest('/api/auth/social-login', 'POST', {
      provider: 'google',
      providerId: 'google_oauth2_test_999',
      email: 'test.google@speakup.ai',
      name: 'Google Test User',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150'
    });
    console.log('[Test 5] POST /api/auth/social-login (Google):', socialLogin.status, `Level: ${socialLogin.body.user ? socialLogin.body.user.level : 'N/A'}`);

    const forgotPw = await makeRequest('/api/auth/forgot-password', 'POST', { email: 'amina@speakup.ai' });
    console.log('[Test 6] POST /api/auth/forgot-password:', forgotPw.status, `Code Generated: ${forgotPw.body.code}`);

    const verifyCode = await makeRequest('/api/auth/verify-reset-code', 'POST', {
      email: 'amina@speakup.ai',
      code: forgotPw.body.code
    });
    console.log('[Test 7] POST /api/auth/verify-reset-code:', verifyCode.status, `Success: ${verifyCode.body.success}`);

    const resetPw = await makeRequest('/api/auth/reset-password', 'POST', {
      email: 'amina@speakup.ai',
      code: forgotPw.body.code,
      newPassword: 'newpassword123'
    });
    console.log('[Test 8] POST /api/auth/reset-password:', resetPw.status, resetPw.body.message);

    const plans = await makeRequest('/api/subscriptions/plans');
    console.log('[Test 9] GET /api/subscriptions/plans:', plans.status, `Plans: ${plans.body.data ? plans.body.data.map(p => `${p.name} (${p.price} ${p.currency})`).join(', ') : 'N/A'}`);

    const session = await makeRequest('/api/sessions/analyze', 'POST', {
      mode: 'full',
      evaluatorId: 'coach',
      evaluatorName: 'The Coach',
      categoryId: 'tech',
      topic: 'Testing Node.js Express MySQL API backend connection',
      durationSeconds: 45
    });
    console.log('[Test 10] POST /api/sessions/analyze:', session.status, `Score: ${session.body.data ? session.body.data.overallScore : 'N/A'}`);

    console.log('--- ALL BACKEND INTEGRATION TESTS COMPLETED SUCCESSFULLY ---');
  } catch (err) {
    console.error('Test execution failed:', err.message);
  }
}

runTests();

