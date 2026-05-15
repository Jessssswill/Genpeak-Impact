const https = require('https');

https.get('https://genshin.jmp.blue/artifacts/all', (res) => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => {
    try {
      const parsed = JSON.parse(data);
      console.log(parsed.slice(0, 2));
    } catch(e) {
      console.log('Error parsing', e);
    }
  });
}).on('error', err => console.log(err));
