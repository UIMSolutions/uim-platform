/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_directory.presentation.pwa.views.dashboard;

import std.array : appender, join;
import std.conv : to;

import uim.platform.identity_directory;

mixin(ShowModule!());

@safe:

struct PwaDashboardView {
  static string render(PwaPageModel model) {
    auto html = appender!string();
    html.put("<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"utf-8\">");
    html.put("<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">");
    html.put("<meta name=\"theme-color\" content=\"#17324d\">");
    html.put("<meta name=\"apple-mobile-web-app-capable\" content=\"yes\">");
    html.put("<meta name=\"apple-mobile-web-app-status-bar-style\" content=\"black-translucent\">");
    html.put("<link rel=\"manifest\" href=\"/pwa/manifest.webmanifest\">");
    html.put("<title>");
    html.put(escapeHtml(model.serviceName));
    html.put("</title>");
    html.put("<style>");
    html.put(baseStyles());
    html.put("</style></head><body>");
    html.put(renderShell(model));
    html.put(renderScript());
    html.put("</body></html>");
    return html.data;
  }

  static string renderManifest() {
    return [
      "{",
      "  \"name\": \"Identity Directory PWA\",",
      "  \"short_name\": \"ID PWA\",",
      "  \"start_url\": \"/pwa\",",
      "  \"scope\": \"/pwa\",",
      "  \"display\": \"standalone\",",
      "  \"background_color\": \"#09131f\",",
      "  \"theme_color\": \"#17324d\",",
      "  \"icons\": []",
      "}"
    ].join("\n");
  }

  static string renderServiceWorker() {
    return [
      "const CACHE_NAME = 'identity-directory-pwa-v1';",
      "const ASSETS = ['/pwa', '/pwa/index.html', '/pwa/manifest.webmanifest'];",
      "",
      "self.addEventListener('install', event => {",
      "  event.waitUntil(caches.open(CACHE_NAME).then(cache => cache.addAll(ASSETS)));",
      "  self.skipWaiting();",
      "});",
      "",
      "self.addEventListener('activate', event => {",
      "  event.waitUntil(self.clients.claim());",
      "});",
      "",
      "self.addEventListener('fetch', event => {",
      "  event.respondWith(",
      "    caches.match(event.request).then(cached => cached || fetch(event.request))",
      "  );",
      "});",
    ].join("\n");
  }

  private static string renderShell(PwaPageModel model) {
    auto html = appender!string();
    html.put("<main class=\"page\"><section class=\"hero\">");
    html.put("<div class=\"hero-copy\"><p class=\"eyebrow\">Portable web app</p>");
    html.put("<h1>");
    html.put(escapeHtml(model.serviceName));
    html.put("</h1><p class=\"lead\">");
    html.put(escapeHtml(model.intro));
    html.put("</p><div class=\"meta-row\"><span>Tenant: ");
    html.put(escapeHtml(model.tenantId));
    html.put("</span><span>");
    html.put(model.domains.length.to!string);
    html.put(" domain groups</span><span>");
    html.put(totalEndpointCount(model).to!string);
    html.put(" operations</span></div></div>");
    html.put("<div class=\"hero-panel\"><h2>Covered use cases</h2><ul>");
    foreach (useCaseName; model.useCases) {
      html.put("<li>");
      html.put(escapeHtml(useCaseName));
      html.put("</li>");
    }
    html.put("</ul><p class=\"panel-note\">");
    html.put("The request console below sends browser requests with the ");
    html.put("X-Tenant-Id header.</p></div>");
    html.put("</section><section class=\"console-grid\">");
    html.put("<article class=\"console\"><div class=\"section-heading\">");
    html.put("<h2>Request console</h2><p>Fill a path, choose a method, ");
    html.put("and run against the live service.</p></div>");
    html.put("<form id=\"request-form\" class=\"request-form\"><label>");
    html.put("Tenant<input id=\"tenant-id\" name=\"tenantId\" value=\"");
    html.put(escapeHtml(model.tenantId));
    html.put("\"></label><label>Base URL<input id=\"base-url\" ");
    html.put("name=\"baseUrl\" value=\"\"></label><label>Method<select ");
    html.put("id=\"method\" name=\"method\">");
    foreach (methodName; ["GET", "POST", "PUT", "DELETE"]) {
      html.put("<option value=\"");
      html.put(methodName);
      html.put("\">");
      html.put(methodName);
      html.put("</option>");
    }
    html.put("</select></label><label>Path<input id=\"path\" ");
    html.put("name=\"path\" value=\"/api/v1/audit-logs\"></label>");
    html.put("<label>JSON body<textarea id=\"body\" name=\"body\" ");
    html.put("rows=\"12\"></textarea></label><div class=\"button-row\">");
    html.put("<button type=\"submit\">Send request</button>");
    html.put("<button type=\"button\" id=\"copy-request\">Copy request</button>");
    html.put("</div></form><pre id=\"response-output\" class=\"response-output\">");
    html.put("Pick an endpoint card to prefill the console.</pre></article>");
    html.put("<aside class=\"catalog\">\n");
    foreach (domain; model.domains) {
      html.put(renderDomainCard(domain));
    }
    html.put("</aside></section></main>");
    return html.data;
  }

  private static string renderDomainCard(PwaDomain domain) {
    auto html = appender!string();
    html.put("<article class=\"domain-card\" data-domain=\"");
    html.put(escapeHtml(domain.key));
    html.put("\"><h2>");
    html.put(escapeHtml(domain.title));
    html.put("</h2><p>");
    html.put(escapeHtml(domain.description));
    html.put("</p><div class=\"endpoint-list\">");
    foreach (endpoint; domain.endpoints) {
      html.put("<button type=\"button\" class=\"endpoint-button\" data-method=\"");
      html.put(endpoint.method);
      html.put("\" data-path=\"");
      html.put(escapeHtml(endpoint.path));
      html.put("\" data-body=\"");
      html.put(escapeHtml(endpoint.body));
      html.put("\" data-summary=\"");
      html.put(escapeHtml(endpoint.summary));
      html.put("\"><strong>");
      html.put(escapeHtml(endpoint.method));
      html.put("</strong><span>");
      html.put(escapeHtml(endpoint.path));
      html.put("</span><em>");
      html.put(escapeHtml(endpoint.summary));
      html.put("</em></button>");
    }
    html.put("</div></article>");
    return html.data;
  }

  private static string renderScript() {
    return [
      "<script>",
      "(() => {",
      "  const baseUrl = document.getElementById('base-url');",
      "  const tenantId = document.getElementById('tenant-id');",
      "  const method = document.getElementById('method');",
      "  const path = document.getElementById('path');",
      "  const body = document.getElementById('body');",
      "  const output = document.getElementById('response-output');",
      "  const form = document.getElementById('request-form');",
      "  const copyButton = document.getElementById('copy-request');",
      "",
      "  baseUrl.value = window.location.origin;",
      "",
      "  document.querySelectorAll('.endpoint-button').forEach(button => {",
      "    button.addEventListener('click', () => {",
      "      method.value = button.dataset.method;",
      "      path.value = button.dataset.path;",
      "      body.value = button.dataset.body || '';",
      "      output.textContent = `${button.dataset.summary}\\n${button.dataset.method} ${button.dataset.path}`;",
      "    });",
      "  });",
      "",
      "  form.addEventListener('submit', async event => {",
      "    event.preventDefault();",
      "    const url = new URL(path.value, baseUrl.value || window.location.origin);",
      "    const requestInit = {",
      "      method: method.value,",
      "      headers: {",
      "        'X-Tenant-Id': tenantId.value || 'default'",
      "      }",
      "    };",
      "    if (!['GET', 'HEAD'].includes(method.value) && body.value.trim().length > 0) {",
      "      requestInit.headers['Content-Type'] = 'application/json';",
      "      requestInit.body = body.value;",
      "    }",
      "",
      "    output.textContent = `Sending ${method.value} ${url.toString()}...`;",
      "    try {",
      "      const response = await fetch(url.toString(), requestInit);",
      "      const text = await response.text();",
      "      output.textContent = `${response.status} ${response.statusText}\\n\\n${text}`;",
      "    } catch (error) {",
      "      output.textContent = `Request failed:\\n${error}`;",
      "    }",
      "  });",
      "",
      "  copyButton.addEventListener('click', async () => {",
      const preview = `${method.value} ${path.value}\\n` +
        `X-Tenant-Id: ${tenantId.value || 'default'}\\n\\n${body.value}`;
      "    await navigator.clipboard.writeText(preview);",
      "    output.textContent = 'Copied the current request sketch to the clipboard.';",
      "  });",
      "",
      "  if ('serviceWorker' in navigator) {",
      "    navigator.serviceWorker.register('/pwa/sw.js').catch(() => null);",
      "  }",
      "})();",
      "</script>",
    ].join("\n");
  }

  private static string baseStyles() {
    return [
      ":root {",
      "  color-scheme: dark;",
      "  --bg: #09131f;",
      "  --panel: rgba(12, 22, 36, 0.86);",
      "  --panel-strong: rgba(18, 34, 54, 0.98);",
      "  --text: #eef5ff;",
      "  --muted: #95a8be;",
      "  --accent: #77d5ff;",
      "  --accent-2: #a3ffcf;",
      "  --border: rgba(131, 168, 206, 0.18);",
      "  --shadow: 0 24px 70px rgba(0, 0, 0, 0.35);",
      "}",
      "* { box-sizing: border-box; }",
      "body {",
      "  margin: 0;",
      "  min-height: 100vh;",
      "  font-family: 'Segoe UI', 'Trebuchet MS', sans-serif;",
      "  color: var(--text);",
      "  background:",
      "    radial-gradient(circle at top left, rgba(119, 213, 255, 0.16), transparent 32%),",
      "    radial-gradient(circle at top right, rgba(163, 255, 207, 0.12), transparent 28%),",
      "    linear-gradient(180deg, #08111b 0%, #0b1623 100%);",
      "}",
      "body::before {",
      "  content: '';",
      "  position: fixed;",
      "  inset: 0;",
      "  background-image:",
      "    linear-gradient(rgba(255,255,255,0.035) 1px, transparent 1px),",
      "    linear-gradient(90deg, rgba(255,255,255,0.035) 1px, transparent 1px);",
      "  background-size: 28px 28px;",
      "  mask-image: linear-gradient(180deg, rgba(0,0,0,0.7), transparent 85%);",
      "  pointer-events: none;",
      "}",
      ".page {",
      "  position: relative;",
      "  z-index: 1;",
      "  max-width: 1500px;",
      "  margin: 0 auto;",
      "  padding: 32px;",
      "}",
      ".hero {",
      "  display: grid;",
      "  grid-template-columns: minmax(0, 1.5fr) minmax(280px, 0.8fr);",
      "  gap: 24px;",
      "  margin-bottom: 28px;",
      "}",
      ".hero-copy, .hero-panel, .console, .domain-card {",
      "  background: var(--panel);",
      "  border: 1px solid var(--border);",
      "  box-shadow: var(--shadow);",
      "  backdrop-filter: blur(18px);",
      "  border-radius: 24px;",
      "}",
      ".hero-copy {",
      "  padding: 32px;",
      "  overflow: hidden;",
      "}",
      ".hero-copy h1 {",
      "  margin: 0;",
      "  font-size: clamp(2.8rem, 6vw, 5rem);",
      "  line-height: 0.95;",
      "  letter-spacing: -0.05em;",
      "}",
      ".eyebrow {",
      "  margin: 0 0 12px;",
      "  color: var(--accent);",
      "  text-transform: uppercase;",
      "  letter-spacing: 0.2em;",
      "  font-size: 0.78rem;",
      "}",
      ".lead {",
      "  max-width: 64ch;",
      "  font-size: 1.06rem;",
      "  color: var(--muted);",
      "  line-height: 1.6;",
      "}",
      ".meta-row {",
      "  display: flex;",
      "  flex-wrap: wrap;",
      "  gap: 12px;",
      "  margin-top: 20px;",
      "}",
      ".meta-row span, .pill {",
      "  padding: 8px 12px;",
      "  border-radius: 999px;",
      "  background: rgba(255,255,255,0.06);",
      "  border: 1px solid var(--border);",
      "  color: var(--text);",
      "  font-size: 0.92rem;",
      "}",
      ".hero-panel {",
      "  padding: 24px;",
      "}",
      ".hero-panel h2, .section-heading h2, .domain-card h2 {",
      "  margin: 0 0 12px;",
      "  letter-spacing: -0.03em;",
      "}",
      ".hero-panel ul {",
      "  margin: 0;",
      "  padding-left: 18px;",
      "  color: var(--muted);",
      "  line-height: 1.8;",
      "}",
      ".panel-note {",
      "  margin: 18px 0 0;",
      "  color: var(--muted);",
      "}",
      ".console-grid {",
      "  display: grid;",
      "  grid-template-columns: minmax(320px, 0.9fr) minmax(360px, 1.1fr);",
      "  gap: 24px;",
      "}",
      ".console, .domain-card {",
      "  padding: 24px;",
      "}",
      ".section-heading p, .domain-card p {",
      "  margin: 0;",
      "  color: var(--muted);",
      "  line-height: 1.6;",
      "}",
      ".request-form {",
      "  display: grid;",
      "  gap: 14px;",
      "  margin-top: 18px;",
      "}",
      ".request-form label {",
      "  display: grid;",
      "  gap: 8px;",
      "  color: var(--muted);",
      "  font-size: 0.95rem;",
      "}",
      ".request-form input, .request-form select, .request-form textarea {",
      "  width: 100%;",
      "  padding: 12px 14px;",
      "  border-radius: 14px;",
      "  border: 1px solid var(--border);",
      "  background: rgba(4, 12, 20, 0.65);",
      "  color: var(--text);",
      "  font: inherit;",
      "}",
      ".request-form textarea {",
      "  min-height: 180px;",
      "  resize: vertical;",
      "}",
      ".button-row {",
      "  display: flex;",
      "  gap: 12px;",
      "  flex-wrap: wrap;",
      "}",
      "button {",
      "  border: 0;",
      "  border-radius: 999px;",
      "  padding: 12px 16px;",
      "  background: linear-gradient(135deg, var(--accent), var(--accent-2));",
      "  color: #03111d;",
      "  font-weight: 700;",
      "  cursor: pointer;",
      "}",
      ".response-output {",
      "  margin-top: 16px;",
      "  min-height: 220px;",
      "  padding: 18px;",
      "  border-radius: 18px;",
      "  background: #04101a;",
      "  border: 1px solid var(--border);",
      "  overflow: auto;",
      "  white-space: pre-wrap;",
      "}",
      ".catalog {",
      "  display: grid;",
      "  gap: 18px;",
      "}",
      ".endpoint-list {",
      "  display: grid;",
      "  gap: 10px;",
      "  margin-top: 16px;",
      "}",
      ".endpoint-button {",
      "  display: grid;",
      "  grid-template-columns: auto 1fr;",
      "  gap: 8px 12px;",
      "  align-items: center;",
      "  text-align: left;",
      "  width: 100%;",
      "  padding: 14px 16px;",
      "  border-radius: 18px;",
      "  background: rgba(255,255,255,0.05);",
      "  border: 1px solid var(--border);",
      "  color: var(--text);",
      "}",
      ".endpoint-button strong {",
      "  display: inline-flex;",
      "  align-items: center;",
      "  justify-content: center;",
      "  min-width: 56px;",
      "  padding: 4px 8px;",
      "  border-radius: 999px;",
      "  background: rgba(119, 213, 255, 0.18);",
      "}",
      ".endpoint-button span {",
      "  font-weight: 600;",
      "}",
      ".endpoint-button em {",
      "  grid-column: 2;",
      "  color: var(--muted);",
      "  font-style: normal;",
      "}",
      "@media (max-width: 1100px) {",
      "  .hero, .console-grid {",
      "    grid-template-columns: 1fr;",
      "  }",
      "}",
      "@media (max-width: 720px) {",
      "  .page { padding: 18px; }",
      "  .hero-copy, .hero-panel, .console, .domain-card { border-radius: 20px; }",
      "}",
    ].join("\n");
  }

  private static string escapeHtml(string value) {
    string result;
    foreach (character; value) {
      final switch (character) {
      case '&': result ~= "&amp;"; break;
      case '<': result ~= "&lt;"; break;
      case '>': result ~= "&gt;"; break;
      case '"': result ~= "&quot;"; break;
      case '\'': result ~= "&#39;"; break;
      default: result ~= character;
      }
    }
    return result;
  }

  private static size_t totalEndpointCount(PwaPageModel model) {
    size_t count;
    foreach (domain; model.domains) {
      count += domain.endpoints.length;
    }
    return count;
  }
}