const http = require('http');

function post(path, data, token) {
  return new Promise((resolve, reject) => {
    const payload = JSON.stringify(data);
    const headers = {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(payload)
    };
    if (token) headers['Authorization'] = 'Bearer ' + token;
    
    const req = http.request({
      hostname: '127.0.0.1',
      port: 5000,
      path: path,
      method: 'POST',
      headers: headers,
      timeout: 10000
    }, res => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, data: JSON.parse(body) });
        } catch (e) {
          resolve({ status: res.statusCode, raw: body });
        }
      });
    });
    req.on('timeout', () => {
      req.destroy();
      reject(new Error('Request timed out'));
    });
    req.on('error', reject);
    req.write(payload);
    req.end();
  });
}

const net = require('net');
const { startServer } = require('../server');

function isPortOpen(port) {
  return new Promise((resolve) => {
    const socket = new net.Socket();
    socket.setTimeout(800);
    socket.once('connect', () => { socket.destroy(); resolve(true); });
    socket.once('error', () => { socket.destroy(); resolve(false); });
    socket.once('timeout', () => { socket.destroy(); resolve(false); });
    socket.connect(port, '127.0.0.1');
  });
}

async function run() {
  let serverInstance = null;
  const running = await isPortOpen(5000);
  if (!running) {
    serverInstance = await startServer(5000);
  }

  const ts = Date.now();
  const email1 = `sarah_${ts}@speakup.ai`;
  const email2 = `david_${ts}@speakup.ai`;

  try {
    console.log('--- STEP 1: Register Sarah ---');
  const u1 = await post('/api/auth/register', { name: 'Sarah Pro', email: email1, password: 'password123' });
  console.log('Sarah registered. User ID:', u1.data.user.id, 'Plan:', u1.data.user.current_plan_id);

  console.log('\n--- STEP 2: Sarah Subscribes (Payment) ---');
  const pay = await post('/api/subscriptions/process-payment', {
    userId: u1.data.user.id,
    email: email1,
    planId: 'pro',
    amount: 5000,
    phoneNumber: '690000000',
    operator: 'MTN',
    paymentMethod: 'MOBILE_MONEY'
  }, u1.data.token);
  console.log('Sarah payment status:', pay.status, 'Success:', pay.data.success, 'Plan:', pay.data.plan?.name);

  console.log('\n--- STEP 3: Register David (New User) ---');
  const u2 = await post('/api/auth/register', { name: 'David Newbie', email: email2, password: 'password123' });
  console.log('David registered. User ID:', u2.data.user.id, 'Plan:', u2.data.user.current_plan_id);

  console.log('\n--- STEP 4: Login Verification ---');
  const loginSarah = await post('/api/auth/login', { email: email1, password: 'password123' });
  console.log('Sarah logged in -> Plan:', loginSarah.data.user.current_plan_id);

  const loginDavid = await post('/api/auth/login', { email: email2, password: 'password123' });
  console.log('David logged in -> Plan:', loginDavid.data.user.current_plan_id);

    if (loginSarah.data.user.current_plan_id === 'pro' && loginDavid.data.user.current_plan_id === 'free') {
      console.log('\n SUCCESS: Subscriptions are strictly isolated per user!');
    } else {
      console.log('\n FAILURE: Unexpected subscription sharing detected!');
    }
  } finally {
    if (serverInstance) {
      serverInstance.close();
    }
    process.exit(0);
  }
}

run().catch(err => console.error('Error running test:', err.message));
