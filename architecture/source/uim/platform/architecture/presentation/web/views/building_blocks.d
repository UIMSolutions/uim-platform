module uim.platform.architecture.presentation.web.views.building_blocks;

import std.ascii : toUpper;
import std.array : appender;
import std.conv : to;
import std.format : format;
import std.string : replace;
import uim.platform.architecture;

mixin(ShowModule!());

@safe:

class BuildingBlockWebView {
    string renderHub(string tenantId) {
        auto t = escapeHtml(tenantId);
        auto links = [
            navLink("architecture", t),
            navLink("solution", t),
            navLink("data", t),
            navLink("business", t),
            navLink("technology", t)
        ];

        auto html = appender!string();
        html ~= "<!doctype html><html><head><meta charset=\"utf-8\"><title>Building Block Web Interface</title>";
        html ~= baseStyles();
        html ~= "</head><body><main class=\"shell\"><h1>TOGAF Building Block Web</h1>";
        html ~= "<p class=\"subtitle\">Tenant: <strong>" ~ t ~ "</strong></p>";
        html ~= "<section class=\"grid\">";
        foreach (item; links)
            html ~= item;
        html ~= "</section></main></body></html>";
        return html.data;
    }

    string renderPage(WebBuildingBlockPageModel model) {
        auto html = appender!string();
        auto tenant = escapeHtml(model.tenantId);
        html ~= "<!doctype html><html><head><meta charset=\"utf-8\"><title>" ~ escapeHtml(model.title) ~ "</title>";
        html ~= baseStyles();
        html ~= "</head><body><main class=\"shell\">";
        html ~= "<nav><a href=\"/web/architecture?tenantId=" ~ tenant ~ "\">Overview</a></nav>";
        html ~= "<h1>" ~ escapeHtml(model.title) ~ "</h1>";
        html ~= "<p class=\"subtitle\">" ~ escapeHtml(model.subtitle) ~ "</p>";
        html ~= "<p class=\"subtitle\">Tenant: <strong>" ~ tenant ~ "</strong></p>";
        html ~= "<table><thead><tr><th>ID</th><th>Name</th><th>Owner</th><th>Status</th><th>Lifecycle</th><th>Version</th><th>Tags</th></tr></thead><tbody>";

        if (model.items.length == 0) {
            html ~= "<tr><td colspan=\"7\" class=\"empty\">No entries available.</td></tr>";
        } else {
            foreach (item; model.items) {
                auto detailLink = "/web/architecture/" ~ model.blockType ~ "/" ~ escapeUrl(item.id) ~ "?tenantId=" ~ tenant;
                html ~= "<tr>";
                html ~= "<td><a href=\"" ~ detailLink ~ "\">" ~ escapeHtml(item.id) ~ "</a></td>";
                html ~= "<td>" ~ escapeHtml(item.name) ~ "</td>";
                html ~= "<td>" ~ escapeHtml(item.owner) ~ "</td>";
                html ~= "<td>" ~ escapeHtml(item.status) ~ "</td>";
                html ~= "<td>" ~ escapeHtml(item.lifecycle) ~ "</td>";
                html ~= "<td>" ~ escapeHtml(item.versionLabel) ~ "</td>";
                html ~= "<td>" ~ escapeHtml(item.tags) ~ "</td>";
                html ~= "</tr>";
            }
        }

        html ~= "</tbody></table></main></body></html>";
        return html.data;
    }

    string renderDetail(WebBuildingBlockDetailModel model) {
        auto html = appender!string();
        auto tenant = escapeHtml(model.tenantId);
        auto backHref = "/web/architecture/" ~ model.blockType ~ "?tenantId=" ~ tenant;

        html ~= "<!doctype html><html><head><meta charset=\"utf-8\"><title>" ~ escapeHtml(model.title) ~ "</title>";
        html ~= baseStyles();
        html ~= "</head><body><main class=\"shell\">";
        html ~= "<nav><a href=\"/web/architecture?tenantId=" ~ tenant ~ "\">Overview</a> | <a href=\"" ~ backHref ~ "\">Back to list</a></nav>";
        html ~= "<h1>" ~ escapeHtml(model.title) ~ "</h1>";
        html ~= "<p class=\"subtitle\">" ~ escapeHtml(model.subtitle) ~ "</p>";
        html ~= "<p class=\"subtitle\">Tenant: <strong>" ~ tenant ~ "</strong></p>";

        if (!model.found) {
            html ~= "<div class=\"empty-box\">Building block not found.</div>";
        } else {
            html ~= "<table><tbody>";
            html ~= row("ID", model.item.id);
            html ~= row("Name", model.item.name);
            html ~= row("Description", model.item.description);
            html ~= row("Owner", model.item.owner);
            html ~= row("Status", model.item.status);
            html ~= row("Lifecycle", model.item.lifecycle);
            html ~= row("Version", model.item.versionLabel);
            html ~= row("Tags", model.item.tags);
            html ~= "</tbody></table>";
        }

        html ~= "</main></body></html>";
        return html.data;
    }

    private string navLink(string blockType, string tenantId) {
        auto name = blockType.length == 0
            ? ""
            : to!string(toUpper(blockType[0])) ~ blockType[1 .. $];
        return "<a class=\"card\" href=\"/web/architecture/" ~ blockType ~ "?tenantId=" ~ tenantId ~ "\">" ~ name ~ "</a>";
    }

    private string escapeHtml(string value) {
        return value
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
    }

    private string escapeUrl(string value) {
        auto encoded = appender!string();
        foreach (ch; value) {
            if ((ch >= 'a' && ch <= 'z') ||
                (ch >= 'A' && ch <= 'Z') ||
                (ch >= '0' && ch <= '9') ||
                ch == '-' || ch == '_' || ch == '.' || ch == '~') {
                encoded ~= ch;
            } else {
                encoded ~= "%";
                encoded ~= format("%02X", cast(ubyte) ch);
            }
        }
        return encoded.data;
    }

    private string row(string label, string value) {
        return "<tr><th>" ~ escapeHtml(label) ~ "</th><td>" ~ escapeHtml(value) ~ "</td></tr>";
    }

    private string baseStyles() {
        return "<style>"
            ~ "body{font-family:Verdana,sans-serif;background:#f6f8fb;color:#1f2937;margin:0;}"
            ~ ".shell{max-width:1100px;margin:0 auto;padding:24px;}"
            ~ "h1{margin:0 0 10px;}"
            ~ ".subtitle{color:#4b5563;margin:4px 0 16px;}"
            ~ ".grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:12px;}"
            ~ ".card{display:block;padding:14px 16px;background:#0f172a;color:#e2e8f0;text-decoration:none;border-radius:10px;text-align:center;font-weight:600;}"
            ~ "table{width:100%;border-collapse:collapse;background:#fff;border:1px solid #d1d5db;}"
            ~ "th,td{padding:10px;border-bottom:1px solid #e5e7eb;text-align:left;font-size:14px;}"
            ~ "thead{background:#eef2ff;}"
            ~ ".empty{text-align:center;color:#6b7280;}"
            ~ ".empty-box{padding:18px;background:#fff8e1;border:1px solid #f1d59a;color:#8a5b00;border-radius:8px;}"
            ~ "nav a{color:#1d4ed8;text-decoration:none;}"
            ~ "</style>";
    }
}
