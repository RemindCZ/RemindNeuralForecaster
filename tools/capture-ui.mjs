import { spawn } from 'node:child_process';
import { mkdirSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';

const [edgePath, outputDirectory] = process.argv.slice(2);
if (!edgePath || !outputDirectory) {
  throw new Error('Usage: node capture-ui.mjs <msedge.exe> <output-directory>');
}

const width = 1920;
const height = 1080;
const debugPort = 9333;
const profile = join(tmpdir(), `remind-marketing-edge-${process.pid}`);
mkdirSync(resolve(outputDirectory), { recursive: true });

const edge = spawn(edgePath, [
  '--headless=new',
  `--remote-debugging-port=${debugPort}`,
  `--user-data-dir=${profile}`,
  `--window-size=${width},${height}`,
  '--force-device-scale-factor=1',
  '--disable-features=Translate,msEdgeShoppingAssistant',
  '--no-first-run',
  '--no-default-browser-check',
  'http://127.0.0.1:7470/'
], { stdio: ['ignore', 'ignore', 'pipe'] });

let edgeError = '';
edge.stderr.on('data', (chunk) => { edgeError += chunk.toString(); });

const delay = (milliseconds) => new Promise((resolveDelay) => setTimeout(resolveDelay, milliseconds));

async function json(url, options = {}) {
  const response = await fetch(url, options);
  if (!response.ok) throw new Error(`${url} returned HTTP ${response.status}`);
  return response.json();
}

async function waitForPage() {
  const deadline = Date.now() + 15000;
  while (Date.now() < deadline) {
    try {
      const pages = await json(`http://127.0.0.1:${debugPort}/json/list`);
      const page = pages.find((item) => item.type === 'page' && item.url.startsWith('http://127.0.0.1:7470/'));
      if (page?.webSocketDebuggerUrl) return page;
    } catch {
      // Edge is still starting.
    }
    await delay(100);
  }
  throw new Error(`Edge DevTools endpoint did not become ready. ${edgeError}`);
}

const page = await waitForPage();
const socket = new WebSocket(page.webSocketDebuggerUrl);
const pending = new Map();
let nextId = 1;

await new Promise((resolveOpen, rejectOpen) => {
  socket.addEventListener('open', resolveOpen, { once: true });
  socket.addEventListener('error', rejectOpen, { once: true });
});

socket.addEventListener('message', (event) => {
  const message = JSON.parse(event.data);
  if (!message.id || !pending.has(message.id)) return;
  const { resolve: resolveCall, reject } = pending.get(message.id);
  pending.delete(message.id);
  if (message.error) reject(new Error(message.error.message));
  else resolveCall(message.result);
});

function call(method, params = {}) {
  return new Promise((resolveCall, reject) => {
    const id = nextId++;
    pending.set(id, { resolve: resolveCall, reject });
    socket.send(JSON.stringify({ id, method, params }));
  });
}

async function evaluate(expression) {
  const result = await call('Runtime.evaluate', {
    expression,
    awaitPromise: true,
    returnByValue: true
  });
  if (result.exceptionDetails) throw new Error(result.exceptionDetails.text || 'Browser evaluation failed');
  return result.result?.value;
}

async function waitFor(expression, timeout = 15000) {
  const deadline = Date.now() + timeout;
  while (Date.now() < deadline) {
    if (await evaluate(`Boolean(${expression})`)) return;
    await delay(100);
  }
  throw new Error(`Timed out waiting for: ${expression}`);
}

async function view(name, scrollExpression = 'window.scrollTo(0, 0)') {
  await evaluate(`document.querySelector('[data-view="${name}"]').click()`);
  await delay(800);
  await evaluate(scrollExpression);
  await delay(300);
}

async function capture(filename) {
  const result = await call('Page.captureScreenshot', {
    format: 'png',
    fromSurface: true,
    captureBeyondViewport: false
  });
  writeFileSync(resolve(outputDirectory, filename), Buffer.from(result.data, 'base64'));
}

try {
  await call('Page.enable');
  await call('Runtime.enable');
  await call('Emulation.setDeviceMetricsOverride', {
    width, height, deviceScaleFactor: 1, mobile: false,
    screenWidth: width, screenHeight: height
  });
  await waitFor(`document.readyState === 'complete' && document.querySelector('#version')?.textContent === '0.8.2'`);
  await waitFor(`document.querySelector('#connection-status')?.textContent === 'WebSocket connected'`);
  await delay(1000);

  await view('overview');
  await capture('01-dashboard.png');

  await view('training', `document.querySelector('#experiment-list').scrollIntoView({block:'center'})`);
  await capture('02-experiment-catalog.png');
  await evaluate(`document.querySelector('#experiment-list .experiment-row')?.click()`);
  await delay(500);
  await evaluate(`window.scrollTo(0, 0)`);
  await capture('03-experiment-detail.png');

  await view('data', `document.querySelector('#snapshot-form').scrollIntoView({block:'start'})`);
  await capture('04-display-names.png');
  await evaluate(`document.querySelector('#snapshot-preview').scrollIntoView({block:'center'})`);
  await delay(300);
  await capture('05-snapshots.png');

  await view('models');
  await capture('06-model-catalog.png');

  await view('data', `document.querySelector('#trash-list').scrollIntoView({block:'center'})`);
  await capture('07-trash.png');
  await evaluate(`document.querySelector('#trash-list button.secondary')?.click()`);
  await waitFor(`document.querySelector('#trash-list')?.textContent.includes('Trash is empty')`);
  await evaluate(`document.querySelector('#snapshot-preview').scrollIntoView({block:'center'})`);
  await delay(300);
  await capture('08-trash-restore.png');

  await view('overview', `document.querySelector('.gpu-card').scrollIntoView({block:'center'})`);
  await capture('09-system-health.png');

  await view('research');
  await capture('10-research-evaluation.png');

  await view('forecast');
  await capture('11-live-forecast.png');
} finally {
  socket.close();
  edge.kill();
  await new Promise((resolveExit) => edge.once('exit', resolveExit));
  rmSync(profile, { recursive: true, force: true });
}

