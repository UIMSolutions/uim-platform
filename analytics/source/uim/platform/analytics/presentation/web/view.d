module uim.platform.analytics.presentation.web.view;

import std.array : appender;
import std.format : format;
import uim.platform.analytics.presentation.web.model;

struct WebView {
  string renderDashboard(WebDashboardModel model) const {
    auto buffer = appender!string();
    buffer.put("<!doctype html><html><head><meta charset='utf-8'>");
    buffer.put("<meta name='viewport' content='width=device-width, initial-scale=1'>");
    buffer.put("<title>Analytics Dashboard</title>");
    buffer.put("<style>");
    buffer.put(
      "body{font-family:Segoe UI,Tahoma,sans-serif;" ~
      "background:linear-gradient(120deg,#f4f8ff,#eef6f2);margin:0;padding:2rem;color:#1e293b}"
    );
    buffer.put(
      ".card{background:#fff;border-radius:16px;padding:1.25rem;" ~
      "box-shadow:0 8px 24px rgba(15,23,42,.08);max-width:760px;margin:auto}"
    );
    buffer.put("h1{margin:0 0 .5rem}.meta{color:#475569;margin-bottom:1rem}li{margin:.35rem 0}");
    buffer.put("</style></head><body>");
    buffer.put("<div class='card'>");
    buffer.put(format("<h1>%s</h1>", model.title));
    buffer.put(format("<div class='meta'>Tenant: %s, Assets: %s</div>", model.tenantId, model.assetCount));
    buffer.put("<ul>");
    foreach (h; model.highlights) buffer.put("<li>" ~ h ~ "</li>");
    buffer.put("</ul></div></body></html>");
    return buffer.data;
  }
}
