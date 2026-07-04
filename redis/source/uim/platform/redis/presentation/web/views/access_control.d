/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.web.views.access_control;

import uim.platform.redis;

import std.format : format;

mixin(ShowModule!());

@safe:

class WebAccessControlView {
    void renderList(HTTPServerResponse res, WebAccessControlModel model) @trusted {
        res.writeBody(buildListHtml(model), cast(int) HTTPStatus.ok, "text/html; charset=utf-8");
    }
    void renderDetail(HTTPServerResponse res, WebAccessControlModel model) @trusted {
        int code = model.hasSelected ? cast(int) HTTPStatus.ok : cast(int) HTTPStatus.notFound;
        res.writeBody(buildDetailHtml(model), code, "text/html; charset=utf-8");
    }
    void renderError(HTTPServerResponse res, int code, string msg) @trusted {
        res.writeBody(buildErrorHtml(code, msg), code, "text/html; charset=utf-8");
    }

    private string buildListHtml(WebAccessControlModel model) {
        auto sb = new StringBuilder();
        sb ~= htmlHead(model.pageTitle) ~ `<h1>` ~ model.pageTitle ~ `</h1>`;
        sb ~= `<table border="1"><tr><th>ID</th><th>CIDR</th><th>Direction</th><th>Action</th><th>Priority</th></tr>`;
        foreach (a; model.rules)
            sb ~= format(`<tr><td><a href="/web/redis/access-controls/%s">%s</a></td><td>%s</td><td>%s</td><td>%s</td><td>%d</td></tr>`,
                a.id.value, a.id.value[0..min(8, a.id.value.length)], a.cidrBlock, a.direction, a.action, a.priority);
        sb ~= `</table>` ~ htmlFoot();
        return sb.data;
    }

    private string buildDetailHtml(WebAccessControlModel model) {
        if (!model.hasSelected) return buildErrorHtml(404, model.errorMessage);
        auto a = model.selected;
        return htmlHead(model.pageTitle) ~ `<h1>` ~ model.pageTitle ~ `</h1><dl>`
            ~ format(`<dt>ID</dt><dd>%s</dd><dt>CIDR Block</dt><dd>%s</dd><dt>Direction</dt><dd>%s</dd><dt>Action</dt><dd>%s</dd><dt>Priority</dt><dd>%d</dd><dt>Instance</dt><dd>%s</dd>`,
                a.id.value, a.cidrBlock, a.direction, a.action, a.priority, a.instanceId.value)
            ~ `</dl><a href="/web/redis/access-controls">Back to list</a>` ~ htmlFoot();
    }

    private string buildErrorHtml(int code, string msg) {
        return htmlHead("Error") ~ `<h1>Error ` ~ code.to!string ~ `</h1><p>` ~ msg ~ `</p><a href="/web/redis/access-controls">Back</a>` ~ htmlFoot();
    }

    private string htmlHead(string title) {
        return `<!DOCTYPE html><html><head><meta charset="utf-8"><title>` ~ title ~ ` - Redis on SAP BTP</title>`
            ~ `<style>body{font-family:sans-serif;margin:2em}table{border-collapse:collapse}th,td{padding:6px 12px}.error{color:red}</style></head><body>`;
    }
    private string htmlFoot() { return `</body></html>`; }
}
