/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.web.views.service_instance;

import uim.platform.redis;
import std.conv : to;
import std.format : format;

mixin(ShowModule!());

@safe:

/// Web View — renders ServiceInstance HTML for the browser UI.
class WebServiceInstanceView {
    void renderList(HTTPServerResponse res, WebServiceInstanceModel model) @trusted {
        auto html = buildListHtml(model);
        res.writeBody(html, cast(int) HTTPStatus.ok, "text/html; charset=utf-8");
    }

    void renderDetail(HTTPServerResponse res, WebServiceInstanceModel model) @trusted {
        auto html = buildDetailHtml(model);
        int code = model.hasSelected ? cast(int) HTTPStatus.ok : cast(int) HTTPStatus.notFound;
        res.writeBody(html, code, "text/html; charset=utf-8");
    }

    void renderError(HTTPServerResponse res, int code, string msg) @trusted {
        auto html = buildErrorHtml(code, msg);
        res.writeBody(html, code, "text/html; charset=utf-8");
    }

    private string buildListHtml(WebServiceInstanceModel model) {
        auto sb = new StringBuilder();
        sb ~= htmlHead(model.pageTitle);
        sb ~= `<h1>` ~ model.pageTitle ~ `</h1>`;
        if (model.errorMessage.length > 0)
            sb ~= `<div class="error">` ~ model.errorMessage ~ `</div>`;
        sb ~= `<table border="1"><tr><th>ID</th><th>Name</th><th>Status</th><th>Region</th><th>Memory</th><th>HA</th></tr>`;
        foreach (i; model.instances)
            sb ~= format(`<tr><td><a href="/web/redis/instances/%s">%s</a></td><td>%s</td><td>%s</td><td>%s</td><td>%dMB</td><td>%s</td></tr>`,
                i.id.value, i.id.value[0..min(8, i.id.value.length)], i.name, i.status.to!string, i.region, i.memoryMb, i.haEnabled ? "yes" : "no");
        sb ~= `</table>`;
        sb ~= htmlFoot();
        return sb.data;
    }

    private string buildDetailHtml(WebServiceInstanceModel model) {
        if (!model.hasSelected)
            return buildErrorHtml(404, model.errorMessage);
        auto i = model.selected;
        auto sb = new StringBuilder();
        sb ~= htmlHead(model.pageTitle);
        sb ~= `<h1>` ~ model.pageTitle ~ `</h1>`;
        sb ~= `<dl>`;
        sb ~= format(`<dt>ID</dt><dd>%s</dd>`, i.id.value);
        sb ~= format(`<dt>Name</dt><dd>%s</dd>`, i.name);
        sb ~= format(`<dt>Status</dt><dd>%s</dd>`, i.status.to!string);
        sb ~= format(`<dt>Hyperscaler</dt><dd>%s</dd>`, i.hyperscaler.to!string);
        sb ~= format(`<dt>Region</dt><dd>%s</dd>`, i.region);
        sb ~= format(`<dt>Redis Version</dt><dd>%s</dd>`, i.redisVersion.to!string);
        sb ~= format(`<dt>Memory MB</dt><dd>%d</dd>`, i.memoryMb);
        sb ~= format(`<dt>TLS</dt><dd>%s</dd>`, i.tlsEnabled ? "yes" : "no");
        sb ~= format(`<dt>HA</dt><dd>%s</dd>`, i.haEnabled ? "yes" : "no");
        sb ~= `</dl>`;
        sb ~= `<a href="/web/redis/instances">Back to list</a>`;
        sb ~= htmlFoot();
        return sb.data;
    }

    private string buildErrorHtml(int code, string msg) {
        return htmlHead("Error " ~ code.to!string)
            ~ `<h1>Error ` ~ code.to!string ~ `</h1><p>` ~ msg ~ `</p>`
            ~ `<a href="/web/redis/instances">Back to list</a>` ~ htmlFoot();
    }

    private string htmlHead(string title) {
        return `<!DOCTYPE html><html><head><meta charset="utf-8"><title>` ~ title
            ~ ` - Redis on SAP BTP</title>`
            ~ `<style>body{font-family:sans-serif;margin:2em}table{border-collapse:collapse}th,td{padding:6px 12px}.error{color:red}</style>`
            ~ `</head><body>`;
    }

    private string htmlFoot() { return `</body></html>`; }
}
