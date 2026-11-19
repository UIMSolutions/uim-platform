/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_directory.presentation.web.views.dashboard;

import std.array : appender;
import std.conv : to;

import uim.platform.identity_directory;

mixin(ShowModule!());

@safe:

struct IdentityDirectoryWebView {
  string renderDashboard(WebPageModel model) const {
    return renderShell(model, renderOverview(model));
  }

  string renderPage(WebPageModel model) const {
    return renderShell(model, renderDomain(model));
  }

  private string renderShell(WebPageModel model, string body) const {
    auto html = appender!string();
    html.put("<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"utf-8\">");
    html.put("<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">");
    html.put("<title>");
    html.put(escapeHtml(model.serviceName ~ " - " ~ model.title));
    html.put("</title><style>");
    html.put(styles());
    html.put("</style></head><body>");
    html.put(nav(model.tenantId));
    html.put(body);
    html.put(requestConsole(model));
    html.put(script());
    html.put("</body></html>");
    return html.data;
  }

  private string nav(string tenantId) const {
    auto html = appender!string();
    html.put("<header class=\"topbar\"><div><p class=\"eyebrow\">Identity Directory MVC</p>");
    html.put("<h1>Management Console</h1></div><form class=\"tenant-form\" method=\"get\">");
    html.put("<label>Tenant<input name=\"tenantId\" value=\"");
    html.put(escapeHtml(tenantId));
    html.put("\"></label><button type=\"submit\">Switch</button></form></header>");
    html.put("<nav class=\"nav-grid\">");
    html.put(navLink("Dashboard", "/web/identity-directory?tenantId=" ~ tenantId));
    html.put(navLink("API clients", "/web/identity-directory/api-clients?tenantId=" ~ tenantId));
    html.put(navLink("Audits", "/web/identity-directory/audit?tenantId=" ~ tenantId));
    html.put(navLink("Users", "/web/identity-directory/users?tenantId=" ~ tenantId));
    html.put(navLink("Groups", "/web/identity-directory/groups?tenantId=" ~ tenantId));
    html.put(navLink("Schemas", "/web/identity-directory/schemas?tenantId=" ~ tenantId));
    html.put(navLink("Password policies", "/web/identity-directory/password-policies?tenantId=" ~ tenantId));
    html.put("</nav>");
    return html.data;
  }

  private string navLink(string label, string href) const {
    return "<a class=\"nav-link\" href=\"" ~ escapeHtml(href) ~ "\">" ~
      escapeHtml(label) ~ "</a>";
  }

  private string renderOverview(WebPageModel model) const {
    auto html = appender!string();
    html.put("<main class=\"page\"><section class=\"hero\"><div class=\"hero-copy\">");
    html.put("<p class=\"eyebrow\">Overview</p><h2>");
    html.put(escapeHtml(model.intro));
    html.put("</h2><div class=\"metric-row\">");
    foreach (metric; model.metrics) {
      html.put(metricChip(metric));
    }
    html.put("</div><ul class=\"highlights\">");
    foreach (highlight; model.highlights) {
      html.put("<li>");
      html.put(escapeHtml(highlight));
      html.put("</li>");
    }
    html.put("</ul></div><aside class=\"hero-panel\"><h3>Quick actions</h3>");
    foreach (action; model.actions) {
      html.put(actionButton(action));
    }
    html.put("</aside></section></main>");
    return html.data;
  }

  private string renderDomain(WebPageModel model) const {
    auto html = appender!string();
    html.put("<main class=\"page\"><section class=\"hero hero-domain\"><div class=\"hero-copy\">");
    html.put("<p class=\"eyebrow\">Tenant: ");
    html.put(escapeHtml(model.tenantId));
    html.put("</p><h2>");
    html.put(escapeHtml(model.title));
    html.put("</h2><p class=\"lead\">");
    html.put(escapeHtml(model.intro));
    html.put("</p><div class=\"metric-row\">");
    foreach (metric; model.metrics) {
      html.put(metricChip(metric));
    }
    html.put("</div></div><aside class=\"hero-panel\"><h3>Request templates</h3>");
    foreach (action; model.actions) {
      html.put(actionButton(action));
    }
    html.put("</aside></section>");
    html.put(tableSection(model.table));
    html.put("</main>");
    return html.data;
  }

  private string tableSection(WebTableModel table) const {
    auto html = appender!string();
    html.put("<section class=\"table-card\"><div class=\"section-heading\"><h3>Resources</h3>");
    html.put("<p>Current tenant records returned by the application use case.</p></div>");
    html.put("<div class=\"table-wrap\"><table><thead><tr>");
    foreach (header; table.headers) {
      html.put("<th>");
      html.put(escapeHtml(header));
      html.put("</th>");
    }
    html.put("</tr></thead><tbody>");
    if (table.rows.length == 0) {
      html.put("<tr><td colspan=\"");
      html.put(table.headers.length.to!string);
      html.put("\">No records available.</td></tr>");
    } else {
      foreach (row; table.rows) {
        html.put("<tr>");
        foreach (cell; row) {
          html.put("<td>");
          html.put(escapeHtml(cell));
          html.put("</td>");
        }
        html.put("</tr>");
      }
    }
    html.put("</tbody></table></div></section>");
    return html.data;
  }

  private string requestConsole(WebPageModel model) const {
    auto html = appender!string();
    html.put("<section class=\"console-card\"><div class=\"section-heading\"><h3>Request console</h3>");
    html.put("<p>Run the current page's request template against the live JSON API.</p></div>");
    html.put("<form id=\"request-form\" class=\"request-form\"><label>");
    html.put("Base URL<input id=\"base-url\" value=\"\"></label>");
    html.put("<label>Path<input id=\"request-path\" value=\"");
    html.put(escapeHtml(model.requestPath));
    html.put("\"></label><label>JSON body<textarea id=\"request-body\" rows=\"12\">");
    html.put(escapeHtml(model.requestBody));
    html.put("</textarea></label><div class=\"button-row\"><button type=\"submit\">Send</button>");
    html.put("<button type=\"button\" id=\"copy-request\">Copy request</button></div></form>");
    html.put("<pre id=\"response-output\" class=\"response-output\">Use the form to exercise the API.</pre></section>");
    return html.data;
  }

  private string metricChip(WebMetricModel metric) const {
    return "<span class=\"metric\"><strong>" ~ escapeHtml(metric.value) ~
      "</strong><em>" ~ escapeHtml(metric.label) ~ "</em></span>";
  }

  private string actionButton(WebActionModel action) const {
    auto html = appender!string();
    html.put("<button type=\"button\" class=\"action-card\" data-path=\"");
    html.put(escapeHtml(action.path));
    html.put("\" data-body=\"");
    html.put(escapeHtml(action.body));
    html.put("\"><span>");
    html.put(escapeHtml(action.label));
    html.put("</span><small>");
    html.put(escapeHtml(action.method ~ " " ~ action.path));
    html.put("</small></button>");
    return html.data;
  }

  private string script() const {
    return ["<script>",
      "(() => {",
      "  const baseUrl = document.getElementById('base-url');",
      "  const requestPath = document.getElementById('request-path');",
      "  const requestBody = document.getElementById('request-body');",
      "  const responseOutput = document.getElementById('response-output');",
      "  const form = document.getElementById('request-form');",
      "  const copyButton = document.getElementById('copy-request');",
      "  baseUrl.value = window.location.origin;",
      "  document.querySelectorAll('.action-card').forEach(button => {",
      "    button.addEventListener('click', () => {",
      "      requestPath.value = button.dataset.path;",
      "      requestBody.value = button.dataset.body || '';",
      "      responseOutput.textContent = `Loaded template for ${button.dataset.path}`;",
      "    });",
      "  });",
      "  form.addEventListener('submit', async event => {",
      "    event.preventDefault();",
      "    const url = new URL(requestPath.value, baseUrl.value || window.location.origin);",
      "    const body = requestBody.value.trim();",
      "    const options = {",
      "      method: body.length > 0 ? 'POST' : 'GET',",
      "      headers: { 'X-Tenant-Id': new URLSearchParams(window.location.search).get('tenantId') || 'default' }",
      "    };",
      "    if (body.length > 0) { options.headers['Content-Type'] = 'application/json'; options.body = body; }",
      "    responseOutput.textContent = `Sending ${options.method} ${url.toString()}...`;",
      "    try {",
      "      const response = await fetch(url.toString(), options);",
      "      responseOutput.textContent = `${response.status} ${response.statusText}\n\n${await response.text()}`;",
      "    } catch (error) {",
      "      responseOutput.textContent = `Request failed:\n${error}`;",
      "    }",
      "  });",
      "  copyButton.addEventListener('click', async () => {",
      "    const tenantId = new URLSearchParams(window.location.search).get('tenantId') || 'default';",
      "    const preview = `X-Tenant-Id: ${tenantId}\n` +",
      "      `\n${requestBody.value}`;",
      "    await navigator.clipboard.writeText(preview);",
      "    responseOutput.textContent = 'Copied the current request sketch to the clipboard.';",
      "  });",
      "})();",
      "</script>",
    ].join("\n");
  }

  private string styles() const {
    return [":root {",
      "  color-scheme: dark;",
      "  --bg: #08111b;",
      "  --panel: rgba(13, 22, 35, 0.84);",
      "  --panel-strong: rgba(18, 33, 51, 0.98);",
      "  --text: #eef5ff;",
      "  --muted: #9ab0c8;",
      "  --accent: #79d7ff;",
      "  --accent-2: #9ef6d0;",
      "  --border: rgba(130, 160, 194, 0.18);",
      "  --shadow: 0 28px 72px rgba(0, 0, 0, 0.32);",
      "}",
      "* { box-sizing: border-box; }",
      "body {",
      "  margin: 0;",
      "  min-height: 100vh;",
      "  font-family: 'Segoe UI', 'Trebuchet MS', sans-serif;",
      "  color: var(--text);",
      "  background: radial-gradient(circle at top left, rgba(121, 215, 255, 0.16), transparent 30%),",
      "    radial-gradient(circle at top right, rgba(158, 246, 208, 0.12), transparent 26%),",
      "    linear-gradient(180deg, #07101a 0%, #0b1726 100%);",
      "}",
      ".topbar, .hero, .table-card, .console-card {",
      "  width: min(1400px, calc(100% - 32px));",
      "  margin: 18px auto 0;",
      "  border-radius: 24px;",
      "  border: 1px solid var(--border);",
      "  background: var(--panel);",
      "  box-shadow: var(--shadow);",
      "  backdrop-filter: blur(18px);",
      "}",
      ".topbar {",
      "  display: flex;",
      "  justify-content: space-between;",
      "  align-items: end;",
      "  gap: 16px;",
      "  padding: 24px 28px;",
      "}",
      ".topbar h1 { margin: 0; letter-spacing: -0.05em; font-size: clamp(2rem, 4vw, 3.4rem); }",
      ".eyebrow {",
      "  margin: 0 0 8px;",
      "  color: var(--accent);",
      "  text-transform: uppercase;",
      "  letter-spacing: 0.18em;",
      "  font-size: 0.78rem;",
      "}",
      ".tenant-form { display: flex; gap: 12px; flex-wrap: wrap; align-items: end; }",
      ".tenant-form label, .request-form label { display: grid; gap: 8px; color: var(--muted); }",
      ".tenant-form input, .request-form input, .request-form textarea {",
      "  width: 100%; padding: 12px 14px; border-radius: 14px; border: 1px solid var(--border);",
      "  background: rgba(4, 12, 20, 0.68); color: var(--text); font: inherit;",
      "}",
      ".tenant-form button, .button-row button {",
      "  border: 0;",
      "  border-radius: 999px;",
      "  padding: 12px 16px;",
      "  background: linear-gradient(135deg, var(--accent), var(--accent-2));",
      "  color: #02101d;",
      "  font-weight: 700;",
      "  cursor: pointer;",
      "}",
      ".nav-grid {",
      "  width: min(1400px, calc(100% - 32px));",
      "  margin: 16px auto 0;",
      "  display: grid;",
      "  grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));",
      "  gap: 12px;",
      "}",
      ".nav-link {",
      "  padding: 12px 16px;",
      "  border-radius: 999px;",
      "  background: rgba(255,255,255,0.05);",
      "  border: 1px solid var(--border);",
      "  color: var(--text);",
      "  text-align: center;",
      "  text-decoration: none;",
      "}",
      ".page { width: min(1400px, calc(100% - 32px)); margin: 0 auto; padding: 18px 0 40px; }",
      ".hero {",
      "  display: grid;",
      "  grid-template-columns: minmax(0, 1.4fr) minmax(320px, 0.9fr);",
      "  gap: 18px;",
      "  padding: 24px;",
      "}",
      ".hero-domain { grid-template-columns: minmax(0, 1.3fr) minmax(340px, 0.9fr); }",
      ".hero-copy h2 { margin: 0; font-size: clamp(1.4rem, 3vw, 2.4rem); letter-spacing: -0.04em; line-height: 1.1; }",
      ".lead { color: var(--muted); line-height: 1.65; max-width: 68ch; }",
      ".metric-row { display: flex; flex-wrap: wrap; gap: 12px; margin-top: 16px; }",
      ".metric {",
      "  padding: 10px 14px;",
      "  border-radius: 999px;",
      "  background: rgba(255,255,255,0.06);",
      "  border: 1px solid var(--border);",
      "}",
      ".metric strong { display: block; font-size: 1.1rem; }",
      ".metric em { color: var(--muted); font-style: normal; font-size: 0.86rem; }",
      ".highlights { margin: 18px 0 0; padding-left: 18px; color: var(--muted); line-height: 1.9; }",
      ".hero-panel, .table-card, .console-card { padding: 24px; }",
      ".section-heading h3, .hero-panel h3 { margin: 0 0 10px; }",
      ".action-card {",
      "  display: grid;",
      "  gap: 6px;",
      "  text-align: left;",
      "  width: 100%;",
      "  padding: 14px 16px;",
      "  margin-top: 12px;",
      "  border-radius: 18px;",
      "  border: 1px solid var(--border);",
      "  background: rgba(255,255,255,0.05);",
      "  color: var(--text);",
      "}",
      ".action-card small { color: var(--muted); }",
      ".table-wrap { overflow: auto; }",
      "table { width: 100%; border-collapse: collapse; }",
      "th, td {",
      "  padding: 12px 14px;",
      "  border-bottom: 1px solid rgba(255,255,255,0.08);",
      "  text-align: left;",
      "  vertical-align: top;",
      "}",
      "th { color: var(--muted); font-size: 0.9rem; }",
      ".request-form { display: grid; gap: 14px; margin-top: 10px; }",
      ".button-row { display: flex; gap: 12px; flex-wrap: wrap; }",
      ".response-output {",
      "  margin-top: 16px;",
      "  min-height: 180px;",
      "  padding: 18px;",
      "  border-radius: 18px;",
      "  background: #040f19;",
      "  border: 1px solid var(--border);",
      "  white-space: pre-wrap;",
      "  overflow: auto;",
      "}",
      "@media (max-width: 980px) {",
      "  .topbar, .hero {",
      "    grid-template-columns: 1fr;",
      "    display: grid;",
      "  }",
      "  .topbar {",
      "    align-items: start;",
      "  }",
      "}",
      "@media (max-width: 720px) {",
      "  .topbar, .hero, .table-card, .console-card {",
      "    width: min(100% - 18px, 1400px);",
      "    border-radius: 20px;",
      "  }",
      "  .page {",
      "    width: min(100% - 18px, 1400px);",
      "  }",
      "}",
    ].join("\n");
  }

  private string escapeHtml(string value) const {
    string result;
    foreach (character; value) {
      switch (character) {
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
}