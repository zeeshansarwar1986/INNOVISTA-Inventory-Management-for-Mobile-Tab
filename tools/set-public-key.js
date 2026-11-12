// Writes the PUBLIC license key into www/license-config.js.
// Source: env PUBLIC_KEY_JWK (JSON) or the file public-key.json in the project root. Optional env OWNER_WHATSAPP.
const fs=require('fs');
let t=process.env.PUBLIC_KEY_JWK;if(!t&&fs.existsSync('public-key.json'))t=fs.readFileSync('public-key.json','utf8');
if(!t){console.error('No public key. Put the key from the Key Generator (Settings > Public key) into public-key.json');process.exit(1)}
let k;try{k=JSON.parse(t)}catch(e){console.error('The public key is not valid JSON');process.exit(1)}
if(k.kty!=='EC'||k.crv!=='P-256'||!k.x||!k.y){console.error('Not a P-256 public key');process.exit(1)}
if(k.d){console.error('STOP: this key contains a private part ("d"). Use only the public key.');process.exit(1)}
const wa=(process.env.OWNER_WHATSAPP||'').replace(/\D/g,'');
fs.writeFileSync('www/license-config.js','window.LICENSE_CONFIG='+JSON.stringify({required:true,publicKey:{kty:k.kty,crv:k.crv,x:k.x,y:k.y},ownerWhatsApp:wa,appName:'INNOVISTA Inventory Management'})+';\n');
console.log('license-config.js written');
