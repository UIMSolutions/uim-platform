/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.web.views.metric;

import uim.platform.redis;

import std.format : format;
mixin(ShowModule!());

@safe:

class WebMetricView {
    void renderList(HTTPServerResponse res, WebMetricModel model) @trusted {
        res.writeBody(buildListHtml(model), cast(int) HTTPStatus.ok, "text/html; charset=utf-8");
    }
    void renderDetail(HTTPServerResponse res, WebMetricModel model) @trusted {
        int code = model.hasSelected ? cast(int) HTTPStatus.ok : cast(int) HTTPStatus.notFound;
        res.writeBody(buildDetailHtml(model), code, "text/html; charset=utf-8");
    }
    void renderError(HTTPServerResponse res, int code, string msg) @trusted {
        res.writeBody(buildErrorHtml(code, msg), code, "text/html; charset=utf-8");
    }

    private string buildListHtml(WebMetricModel model) {
        auto sb = new StringBuilder();
        sb ~= htmlHead(model.pageTitle) ~ `<h1>` ~ model.pageTitle ~ `</h1>`;
        sb ~= `<table border="1"><tr><th>ID</th><th>Timestamp</th><th>Mem Used</th><th>Clients</th><th>Hit Rate</th></tr>`;
        foreach (m; model.metrics)
            sb ~= format(`<tr><td><a href="/web/redis/metrics/%s">%s</a></td><td>%d</td><td>%dMB</td><td>%d</td><td>%.1f%%</td></tr>`,
                m.id.value, m.id.value[0..min(8, m.id.value.length)], m.timestamp_, m.memoryUsedMb, m.connectedClients, m.hitRate * 100);
        sb ~= `</table>` ~ htmlFoot();
        return sb.data;
    }

    private string buildDetailHtml(WebMetricModel model) {
        if (!model.hasSelected) return buildErrorHtml(404, model.errorMessage);
        auto m = model.selected;
        return htmlHead(model.pageTitle) ~ `<h1>` ~ model.pageTitle ~ `</h1><dl>`
            ~ format(`<dt>ID</dt><dd>%s</dd><dt>Timestamp</dt><dd>%d</dd><dt>Memory Used</dt><dd>%dMB</dd><dt>Memory Total</dt><dd>%dMB</dd><dt>Clients</dt><dd>%d</dd><dt>Commands/sec</dt><dd>%d</dd><dt>Hit Rate</dt><dd>%.2f%%</dd><dt>Evicted Keys</dt><dd>%d</dd>`,
                m.id.value, m.timestamp_, m.memoryUsedMb, m.memoryTotalMb, m.connectedClients, m.commandsPerSecond, m.hitRate * 100, m.evictedKeys)
            ~ `</dl><a href="/web/redis/metrics">Back to list</a>` ~ htmlFoot();
    }

    private string buildErrorHtml(int code, string msg) {
        return htmlHead("Error") ~ `<h1>Error ` ~ code.to!string ~ `</h1><p>` ~ msg ~ `</p><a href="/web/redis/metrics">Back</a>` ~ htmlFoot();
    }

    private string htmlHead(string title) {
        return `<!DOCTYPE html><html><head><meta charset="utf-8"><title>` ~ title ~ ` - Redis on SAP BTP</title>`
            ~ `<style>body{font-family:sans-serif;margin:2em}table{border-collapse:collapse}th,td{padding:6px 12px}.error{color:red}</style></head><body>`;
    }
    private string htmlFoot() { return `</body></html>`; }
}
