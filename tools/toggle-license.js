// Toggle licensing requirement between true and false
const fs = require('fs');
const p = 'www/license-config.js';
let content = fs.readFileSync(p, 'utf8');
const match = content.match(/"required"\s*:\s*(true|false)/);
if (match) {
  const current = match[1] === 'true';
  const next = !current;
  content = content.replace(match[0], `"required":${next}`);
  fs.writeFileSync(p, content, 'utf8');
  console.log(`Licensing required is now set to: ${next}`);
} else {
  console.log('Could not find required field in license-config.js');
}

