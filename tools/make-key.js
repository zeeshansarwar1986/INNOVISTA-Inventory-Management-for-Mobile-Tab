// Generates an activation key for INNOVISTA Inventory using the private key in keygen/owner-keys.json
const fs = require('fs');
const enc = new TextEncoder();
const b64u = b => Buffer.from(b).toString('base64url');

async function main() {
  const args = process.argv.slice(2);
  const devId = (args[0] || '').toUpperCase().trim();
  const cust = args[1] || 'Customer';
  const exp = args[2] || 'LIFETIME';

  if (!devId) {
    console.log('Usage: bun tools/make-key.js <DEVICE-ID> [CustomerName] [LIFETIME|YYYY-MM-DD]');
    console.log('Example: bun tools/make-key.js 4K8P-7W9X-2M3N-5Q1R "Shop" LIFETIME');
    process.exit(1);
  }

  const keys = JSON.parse(fs.readFileSync('keygen/owner-keys.json', 'utf8'));
  const privKey = await crypto.subtle.importKey('jwk', keys.priv, {name: 'ECDSA', namedCurve: 'P-256'}, false, ['sign']);

  const payloadStr = 'INV1|' + devId + '|' + exp + '|' + cust;
  const payload = enc.encode(payloadStr);
  const sig = await crypto.subtle.sign({name: 'ECDSA', hash: 'SHA-256'}, privKey, payload);

  const key = 'INV1-' + b64u(payload) + '.' + b64u(sig);
  console.log('\n--- INNOVISTA ACTIVATION KEY ---');
  console.log('Device ID:  ', devId);
  console.log('Customer:   ', cust);
  console.log('Expiry:     ', exp);
  console.log('Key:        ', key);
  console.log('--------------------------------\n');
}

main().catch(console.error);

