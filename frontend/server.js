/**
 * 开发服务器 — 静态文件服务 + API 代理到后端 Spring Boot
 * 后端地址: http://localhost:8080
 */
const http = require('http');
const fs = require('fs');
const path = require('path');

const BACKEND_PORT = 8080;
const FRONTEND_PORT = 3000;
const ROOT = __dirname;
const DATA_ROOT = path.join(__dirname, '..', 'data');

const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css',
  '.js': 'application/javascript; charset=utf-8',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
};

const server = http.createServer((req, res) => {
  const url = req.url;

  // ======== 代理 API 请求到后端 ========
  if (url.startsWith('/api/')) {
    const options = {
      hostname: 'localhost',
      port: BACKEND_PORT,
      path: url,
      method: req.method,
      headers: { ...req.headers, host: `localhost:${BACKEND_PORT}` },
    };

    const proxyReq = http.request(options, (proxyRes) => {
      // 移除 CORS 相关响应头（由前端代理统一处理）
      const headers = { ...proxyRes.headers };
      delete headers['access-control-allow-origin'];
      res.writeHead(proxyRes.statusCode, headers);
      proxyRes.pipe(res);
    });

    proxyReq.on('error', () => {
      res.writeHead(502, { 'Content-Type': 'application/json; charset=utf-8' });
      res.end(JSON.stringify({ code: 502, msg: '后端服务不可用，请确认 Spring Boot 已启动' }));
    });

    req.pipe(proxyReq);
    return;
  }

  // ======== 静态文件服务 ========
  // 默认路由：/ 返回 login.html（首页是登录页）
  let filePath = url === '/' ? '/login.html' : decodeURIComponent(url);

  // /data/ 路径从项目根目录的 data/ 读取
  const baseDir = filePath.startsWith('/data/') ? DATA_ROOT : ROOT;
  filePath = path.join(baseDir, filePath.startsWith('/data/') ? filePath.slice(6) : filePath);

  // favicon.ico 不存在时不报错
  if (url === '/favicon.ico') {
    res.writeHead(204);
    res.end();
    return;
  }

  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.writeHead(404, { 'Content-Type': 'text/html; charset=utf-8' });
      res.end('<h1>404 Not Found</h1>');
      return;
    }
    const ext = path.extname(filePath);
    res.writeHead(200, { 'Content-Type': MIME[ext] || 'application/octet-stream' });
    res.end(data);
  });
});

server.listen(FRONTEND_PORT, () => {
  console.log('');
  console.log('  🏛️  非遗文化数字化传播系统');
  console.log('  ─────────────────────────────');
  console.log(`  🌐 前端:  http://localhost:${FRONTEND_PORT}`);
  console.log(`  🔗 API:   http://localhost:${BACKEND_PORT}/api/`);
  console.log('');
});
