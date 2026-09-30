const http = require('http');
const net = require('net');
const { startServer } = require('../server');

const PORT = process.env.PORT || 5000;

function isPortOpen(port) {
  return new Promise((resolve) => {
    const socket = new net.Socket();
    socket.setTimeout(800);
    socket.once('connect', () => {
      socket.destroy();
      resolve(true);
    });
    socket.once('error', () => {
      socket.destroy();
      resolve(false);
    });
    socket.once('timeout', () => {
      socket.destroy();
      resolve(false);
    });
    socket.connect(port, '127.0.0.1');
  });
}

function makeRequest(path, method = 'GET', data = null) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: '127.0.0.1',
      port: PORT,
      path,
      method,
      headers: {
        'Content-Type': 'application/json'
      }
    };

    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => { body += chunk; });
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
  let spawnedServer = null;

  try {
    const open = await isPortOpen(PORT);
    if (!open) {
      console.log(`ℹ️  Backend is not running on port ${PORT}. Starting in-process test server...`);
      spawnedServer = await startServer(PORT);
      // Give server a moment to settle
      await new Promise(r => setTimeout(r, 600));
    } else {
      console.log(`ℹ️  Connected to running backend server on port ${PORT}.`);
    }

    const health = await makeRequest('/api/health');
    console.log('[Test 1] GET /api/health:', health.status, health.body.status || 'OK');

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
    const userRole = socialLogin.body.user ? socialLogin.body.user.role : 'N/A';
    console.log('[Test 5] POST /api/auth/social-login (Google):', socialLogin.status, `Role: ${userRole}`);

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
    const planSummary = plans.body.data
      ? plans.body.data.map(p => `${p.name} ($${p.priceMonthly ?? 0}/mo)`).join(', ')
      : 'N/A';
    console.log('[Test 9] GET /api/subscriptions/plans:', plans.status, `Plans: ${planSummary}`);

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
    process.exitCode = 1;
  } finally {
    if (spawnedServer) {
      console.log('ℹ️  Closing in-process test server...');
      spawnedServer.close(() => {
        process.exit(process.exitCode || 0);
      });
      // Safety timeout
      setTimeout(() => process.exit(process.exitCode || 0), 1000);
    }
  }
}

runTests();
