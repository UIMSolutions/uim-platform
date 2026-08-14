module uim.platform.architecture.presentation.pwa.views.building_blocks;

import std.ascii : toUpper;
import std.array : appender;
import std.conv : to;
import std.string : replace;
import uim.platform.architecture;

mixin(ShowModule!());

@safe:

class BuildingBlockPwaView {
    string renderHub(string tenantId) {
        auto tenant = escapeHtml(tenantId);
        auto html = appender!string();

        html ~= documentHead("Architecture PWA", true);
        html ~= "<main class=\"shell\"><h1>Architecture Building Blocks PWA</h1>";
        html ~= "<p class=\"subtitle\">Tenant: <strong>" ~ tenant ~ "</strong></p>";
        html ~= "<section class=\"grid\">";
        html ~= navCard("architecture", tenant);
        html ~= navCard("solution", tenant);
        html ~= navCard("data", tenant);
        html ~= navCard("business", tenant);
        html ~= navCard("technology", tenant);
        html ~= "</section></main>";
        html ~= scriptFooter();
        html ~= "</body></html>";
        return html.data;
    }

    string renderPage(PwaBuildingBlockPageModel model) {
        auto tenant = escapeHtml(model.tenantId);
        auto html = appender!string();

        html ~= documentHead(model.title, true);
        html ~= "<main class=\"shell\">";
        html ~= "<nav><a href=\"/pwa/architecture?tenantId=" ~ tenant ~ "\">PWA Home</a></nav>";
        html ~= "<h1>" ~ escapeHtml(model.title) ~ "</h1>";
        html ~= "<p class=\"subtitle\">" ~ escapeHtml(model.subtitle) ~ "</p>";
        html ~= "<table><thead><tr><th>ID</th><th>Name</th><th>Status</th><th>Owner</th><th>Version</th></tr></thead><tbody>";

        if (model.items.length == 0) {
            html ~= "<tr><td colspan=\"5\" class=\"empty\">No entries available.</td></tr>";
        } else {
            foreach (item; model.items) {
                auto href = "/pwa/architecture/" ~ model.blockType ~ "/" ~ item.id ~ "?tenantId=" ~ tenant;
                html ~= "<tr>";
                html ~= "<td><a href=\"" ~ escapeHtml(href) ~ "\">" ~ escapeHtml(item.id) ~ "</a></td>";
                html ~= "<td>" ~ escapeHtml(item.name) ~ "</td>";
                html ~= "<td>" ~ escapeHtml(item.status) ~ "</td>";
                html ~= "<td>" ~ escapeHtml(item.owner) ~ "</td>";
                html ~= "<td>" ~ escapeHtml(item.versionLabel) ~ "</td>";
                html ~= "</tr>";
            }
        }

        html ~= "</tbody></table></main>";
        html ~= scriptFooter();
        html ~= "</body></html>";
        return html.data;
    }

    string renderDetail(PwaBuildingBlockDetailModel model) {
        auto tenant = escapeHtml(model.tenantId);
        auto html = appender!string();

        html ~= documentHead(model.title, true);
        html ~= "<main class=\"shell\">";
        html ~= "<nav><a href=\"/pwa/architecture?tenantId=" ~ tenant ~ "\">PWA Home</a> | <a href=\"/pwa/architecture/" ~ model.blockType ~ "?tenantId=" ~ tenant ~ "\">Back to list</a></nav>";
        html ~= "<h1>" ~ escapeHtml(model.title) ~ "</h1>";

        if (!model.found) {
            html ~= "<div class=\"empty\">Building block not found.</div>";
        } else {
            html ~= "<article class=\"detail\">";
            html ~= detailRow("ID", model.item.id);
            html ~= detailRow("Name", model.item.name);
            html ~= detailRow("Description", model.item.description);
            html ~= detailRow("Owner", model.item.owner);
            html ~= detailRow("Status", model.item.status);
            html ~= detailRow("Lifecycle", model.item.lifecycle);
            html ~= detailRow("Version", model.item.versionLabel);
            html ~= detailRow("Tags", model.item.tags);
            html ~= "</article>";
        }

        html ~= "</main>";
        html ~= scriptFooter();
        html ~= "</body></html>";
        return html.data;
    }

    string manifest() {
        return "{"
            ~ "\"name\":\"Architecture Building Blocks\"," 
            ~ "\"short_name\":\"ArchBlocks\"," 
            ~ "\"start_url\":\"/pwa/architecture?tenantId=default\"," 
            ~ "\"display\":\"standalone\"," 
            ~ "\"background_color\":\"#f4f7fb\"," 
            ~ "\"theme_color\":\"#0f172a\"," 
            ~ "\"icons\":[{\"src\":\"data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='192' height='192'%3E%3Crect width='192' height='192' fill='%230f172a'/%3E%3Ctext x='96' y='108' text-anchor='middle' font-size='64' fill='%23ffffff'%3EA%3C/text%3E%3C/svg%3E\",\"sizes\":\"192x192\",\"type\":\"image/svg+xml\"}]"
            ~ "}";
    }

    string serviceWorker() {
        return "const CACHE='architecture-pwa-v1';\n"
            ~ "const ASSETS=['/pwa/architecture','/pwa/architecture/manifest.webmanifest'];\n"
            ~ "self.addEventListener('install',e=>{e.waitUntil(caches.open(CACHE).then(c=>c.addAll(ASSETS)));});\n"
            ~ "self.addEventListener('fetch',e=>{if(e.request.method!=='GET')return; e.respondWith(caches.match(e.request).then(r=>r||fetch(e.request)));});\n";
    }

    private string navCard(string blockType, string tenantId) {
        auto title = blockType.length == 0 ? "" : to!string(toUpper(blockType[0])) ~ blockType[1 .. $];
        return "<a class=\"card\" href=\"/pwa/architecture/" ~ blockType ~ "?tenantId=" ~ tenantId ~ "\">" ~ title ~ "</a>";
    }

    private string detailRow(string label, string value) {
        return "<div class=\"row\"><span class=\"label\">" ~ escapeHtml(label) ~ "</span><span class=\"value\">" ~ escapeHtml(value) ~ "</span></div>";
    }

    private string documentHead(string title, bool enablePwa) {
        auto html = appender!string();
        html ~= "<!doctype html><html><head><meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width,initial-scale=1\">";
        html ~= "<meta name=\"theme-color\" content=\"#0f172a\"><title>" ~ escapeHtml(title) ~ "</title>";
        if (enablePwa) {
            html ~= "<link rel=\"manifest\" href=\"/pwa/architecture/manifest.webmanifest\">";
        }
        html ~= "<style>"
            ~ "body{margin:0;font-family:'Trebuchet MS',Verdana,sans-serif;background:linear-gradient(160deg,#f4f7fb,#e5ebf5);color:#111827;}"
            ~ ".shell{max-width:960px;margin:0 auto;padding:24px;}"
            ~ ".subtitle{color:#475569;}"
            ~ ".grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(170px,1fr));gap:12px;}"
            ~ ".card{display:block;padding:14px 16px;border-radius:10px;background:#0f172a;color:#e2e8f0;text-decoration:none;font-weight:700;text-align:center;}"
            ~ "table{width:100%;border-collapse:collapse;background:#fff;border-radius:10px;overflow:hidden;}"
            ~ "th,td{padding:10px;border-bottom:1px solid #e2e8f0;text-align:left;}"
            ~ "th{background:#dbe4f2;}"
            ~ "a{color:#1d4ed8;}"
            ~ ".detail{background:#fff;padding:16px;border-radius:10px;border:1px solid #dbe4f2;}"
            ~ ".row{display:flex;gap:12px;padding:8px 0;border-bottom:1px solid #e5e7eb;}"
            ~ ".label{min-width:120px;font-weight:700;color:#334155;}"
            ~ ".value{flex:1;color:#1f2937;}"
            ~ ".empty{background:#fff7ed;color:#9a3412;padding:14px;border-radius:10px;border:1px solid #fed7aa;}"
            ~ "</style></head><body>";
        return html.data;
    }

    private string scriptFooter() {
        return "<script>if('serviceWorker' in navigator){navigator.serviceWorker.register('/pwa/architecture/sw.js').catch(()=>{});}</script>";
    }

    private string escapeHtml(string value) {
        return value
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
    }
}
