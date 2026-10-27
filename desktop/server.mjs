// The desktop's MCP server, on one port behind one token:
// - /mcp: the screen, as the model vendors' computer-use tools see it: screenshot, zoom, click,
//   type, key, scroll, drag, through xdotool on the X display.
// - /playwright/*: Playwright MCP, attached to the desktop's own Chromium (the page, by its
//   accessibility tree), proxied as it is.
// Every request but /healthz needs `Authorization: Bearer $DESKTOP_TOKEN`.
import { execFile } from 'node:child_process';
import { timingSafeEqual } from 'node:crypto';
import http from 'node:http';
import { promisify } from 'node:util';
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StreamableHTTPServerTransport } from '@modelcontextprotocol/sdk/server/streamableHttp.js';
import { z } from 'zod';

const run = promisify(execFile);
const PORT = Number(process.env.DESKTOP_MCP_PORT ?? 8931);
const PLAYWRIGHT = Number(process.env.PLAYWRIGHT_MCP_PORT ?? 8932);
const TOKEN = process.env.DESKTOP_TOKEN ?? '';
const env = { ...process.env, DISPLAY: process.env.DISPLAY ?? ':1' };
const [WIDTH, HEIGHT] = (process.env.DESKTOP_SIZE ?? '1280x800').split('x').map(Number);

if (!TOKEN) {
  console.error('DESKTOP_TOKEN is not set: refusing to serve the screen without a token');
  process.exit(1);
}

const xdo = (...args) => run('xdotool', args.map(String), { env });
const png = async (crop) => {
  const args = ['-silent', '-window', 'root'];
  if (crop) args.push('-crop', `${crop.w}x${crop.h}+${crop.x}+${crop.y}`, '+repage');
  const { stdout } = await run('import', [...args, 'png:-'], {
    env,
    encoding: 'buffer',
    maxBuffer: 64 * 1024 * 1024,
  });
  return stdout.toString('base64');
};
const image = async (crop) => ({
  content: [{ type: 'image', data: await png(crop), mimeType: 'image/png' }],
});
const done = (text = 'ok') => ({ content: [{ type: 'text', text }] });
const x = z.number().int().min(0).max(WIDTH - 1).describe(`Pixels from the left, 0 to ${WIDTH - 1}`);
const y = z.number().int().min(0).max(HEIGHT - 1).describe(`Pixels from the top, 0 to ${HEIGHT - 1}`);
const BUTTONS = { left: 1, middle: 2, right: 3 };

function screenServer() {
  const s = new McpServer({ name: 'desktop', version: '1.0.0' });
  s.registerTool(
    'screenshot',
    { description: `The whole screen, ${WIDTH}x${HEIGHT} pixels, as a PNG.` },
    () => image(),
  );
  s.registerTool(
    'zoom',
    {
      description: 'A region of the screen at full resolution, to read small text.',
      inputSchema: { x0: x, y0: y, x1: x, y1: y },
    },
    ({ x0, y0, x1, y1 }) =>
      image({ x: Math.min(x0, x1), y: Math.min(y0, y1), w: Math.abs(x1 - x0) + 1, h: Math.abs(y1 - y0) + 1 }),
  );
  s.registerTool(
    'click',
    {
      description: 'Click at a point: left by default, `count: 2` for a double click.',
      inputSchema: {
        x,
        y,
        button: z.enum(['left', 'middle', 'right']).default('left'),
        count: z.number().int().min(1).max(3).default(1),
      },
    },
    async ({ x, y, button, count }) => {
      await xdo('mousemove', '--sync', x, y, 'click', '--repeat', count, BUTTONS[button]);
      return done();
    },
  );
  s.registerTool(
    'move',
    { description: 'Move the pointer, to hover.', inputSchema: { x, y } },
    async ({ x, y }) => {
      await xdo('mousemove', '--sync', x, y);
      return done();
    },
  );
  s.registerTool(
    'drag',
    {
      description: 'Press the left button at one point, release it at another.',
      inputSchema: { from_x: x, from_y: y, to_x: x, to_y: y },
    },
    async (a) => {
      await xdo('mousemove', '--sync', a.from_x, a.from_y, 'mousedown', 1);
      await xdo('mousemove', '--sync', a.to_x, a.to_y, 'mouseup', 1);
      return done();
    },
  );
  s.registerTool(
    'scroll',
    {
      description: 'Scroll at a point, by wheel clicks.',
      inputSchema: {
        x,
        y,
        direction: z.enum(['up', 'down', 'left', 'right']),
        amount: z.number().int().min(1).max(30).default(3),
      },
    },
    async ({ x, y, direction, amount }) => {
      const wheel = { up: 4, down: 5, left: 6, right: 7 }[direction];
      await xdo('mousemove', '--sync', x, y, 'click', '--repeat', amount, wheel);
      return done();
    },
  );
  s.registerTool(
    'type',
    { description: 'Type text where the focus is.', inputSchema: { text: z.string().max(4000) } },
    async ({ text }) => {
      await xdo('type', '--delay', 12, '--', text);
      return done();
    },
  );
  s.registerTool(
    'key',
    {
      description: 'Press keys, xdotool names, space between presses: "ctrl+l", "Return", "ctrl+shift+t".',
      inputSchema: { keys: z.string().max(200) },
    },
    async ({ keys }) => {
      await xdo('key', '--', ...keys.split(/\s+/).filter(Boolean));
      return done();
    },
  );
  s.registerTool(
    'cursor_position',
    { description: 'Where the pointer is.' },
    async () => {
      const { stdout } = await xdo('getmouselocation', '--shell');
      const p = Object.fromEntries(stdout.trim().split('\n').map((l) => l.split('=')));
      return done(JSON.stringify({ x: Number(p.X), y: Number(p.Y) }));
    },
  );
  s.registerTool(
    'wait',
    {
      description: 'Wait, for a page to load.',
      inputSchema: { seconds: z.number().min(0.1).max(30) },
    },
    async ({ seconds }) => {
      await new Promise((r) => setTimeout(r, seconds * 1000));
      return done();
    },
  );
  return s;
}

const authorized = (req) => {
  const got = Buffer.from(req.headers.authorization ?? '');
  const want = Buffer.from(`Bearer ${TOKEN}`);
  return got.length === want.length && timingSafeEqual(got, want);
};

function proxyToPlaywright(req, res) {
  const path = req.url.replace(/^\/playwright/, '') || '/';
  // Playwright MCP serves only requests addressed to the host it listens on, by that name.
  const headers = { ...req.headers, host: `localhost:${PLAYWRIGHT}` };
  delete headers.authorization;
  const up = http.request(
    { host: '127.0.0.1', port: PLAYWRIGHT, path, method: req.method, headers },
    (r) => {
      res.writeHead(r.statusCode ?? 502, r.headers);
      r.pipe(res);
    },
  );
  up.on('error', () => {
    if (!res.headersSent) res.writeHead(502).end('playwright mcp is not up');
  });
  req.pipe(up);
}

http
  .createServer(async (req, res) => {
    if (req.url === '/healthz') return res.writeHead(200).end('ok');
    if (!authorized(req)) return res.writeHead(401).end('unauthorized');
    if (req.url.startsWith('/playwright')) return proxyToPlaywright(req, res);
    if (!req.url.startsWith('/mcp')) return res.writeHead(404).end();
    // Stateless: a server and a transport per request, nothing kept between calls.
    const server = screenServer();
    const transport = new StreamableHTTPServerTransport({ sessionIdGenerator: undefined });
    res.on('close', () => {
      transport.close();
      server.close();
    });
    try {
      await server.connect(transport);
      await transport.handleRequest(req, res);
    } catch (err) {
      if (!res.headersSent) res.writeHead(500).end(String(err));
    }
  })
  .listen(PORT, '::', () => console.log(`desktop mcp on :${PORT}`));
