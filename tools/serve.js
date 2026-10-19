// Tiny local web server for testing on the laptop.
// Usage: node tools/serve.js   then open http://localhost:5190 (phone-frame preview)
const http = require('http'), fs = require('fs'), path = require('path');
const root = path.join(__dirname, '..');
const port = Number(process.env.PORT) || 5190;
const types = { '.html': 'text/html', '.js': 'text/javascript', '.json': 'application/json', '.png': 'image/png', '.css': 'text/css', '.svg': 'image/svg+xml', '.woff2': 'font/woff2', '.webp': 'image/webp' };

http.createServer((req, res) => {
  let p = decodeURIComponent(req.url.split('?')[0]);
  if (p === '/') p = '/tools/phone.html';
  if (p.endsWith('/')) p += 'index.html';
  const file = path.join(root, p);
  if (!file.startsWith(root)) { res.writeHead(403); return res.end(); }
  fs.readFile(file, (err, data) => {
    if (err) { res.writeHead(404); return res.end('Not found'); }
    res.writeHead(200, { 'Content-Type': types[path.extname(file)] || 'application/octet-stream', 'Cache-Control': 'no-store' });
    res.end(data);
  });
}).listen(port, () => console.log(`NutriLoop test server: http://localhost:${port}`));
