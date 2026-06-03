module uim.platform.analytics.presentation.gui.view;

import std.array : appender;
import uim.platform.analytics.presentation.gui.model;

struct GuiView {
  string render(GuiModel model) const {
    auto buffer = appender!string();
    buffer.put("<!doctype html><html><head><meta charset='utf-8'>");
    buffer.put("<meta name='viewport' content='width=device-width, initial-scale=1'>");
    buffer.put("<title>Analytics GUI</title>");
    buffer.put("<style>");
    buffer.put("body{font-family:Verdana,sans-serif;background:#f7fafc;margin:0;padding:1.25rem}");
    buffer.put("h1{margin:.25rem 0}.sub{color:#4a5568;margin-bottom:1rem}");
    buffer.put(".grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:1rem}");
    buffer.put(
      ".tile{background:#fff;border:1px solid #e2e8f0;border-radius:14px;" ~
      "padding:1rem;box-shadow:0 4px 14px rgba(0,0,0,.06)}"
    );
    buffer.put("</style></head><body>");
    buffer.put("<h1>" ~ model.heading ~ "</h1>");
    buffer.put("<div class='sub'>" ~ model.subtitle ~ "</div>");
    buffer.put("<div class='grid'>");
    foreach (tile; model.tiles) buffer.put("<div class='tile'>" ~ tile ~ "</div>");
    buffer.put("</div></body></html>");
    return buffer.data;
  }
}
