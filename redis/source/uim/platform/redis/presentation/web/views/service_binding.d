/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.web.views.service_binding;

import uim.platform.redis;

import std.format : format;
mixin(ShowModule!());

@safe:

class WebServiceBindingView {
    void renderList(HTTPServerResponse res, WebServiceBindingModel model) @trusted {
        res.writeBody(buildListHtml(model), cast(int) HTTPStatus.ok, "text/html; charset=utf-8");
    }

    void renderDetail(HTTPServerResponse res, WebServiceBindingModel model) @trusted {
        int code = model.hasSelected ? cast(int) HTTPStatus.ok : cast(int) HTTPStatus.notFound;
        res.writeBody(buildDetailHtml(model), code, "text/html; charset=utf-8");
    }

    void renderError(HTTPServerResponse res, int code, string msg) @trusted {
        res.writeBody(buildErrorHtml(code, msg), code, "text/html; charset=utf-8");
    }

    private string buildListHtml(WebServiceBindingModel model) {
        auto sb = new StringBuilder();
        sb ~= htmlHead(model.pageTitle);
        sb ~= `<h1>` ~ model.pageTitle ~ `</h1>`;
        if (model.errorMessage.length > 0) sb ~= `<div class="error">` ~ model.errorMessage ~ `</div>`;
        sb ~= `<table border="1"><tr><th>ID</th><th>Name</th><th>Instance</th><th>App</th><th>Status</th></tr>`;
        foreach (b; model.bindings)
            sb ~= format(`<tr><td><a href="/web/redis/bindings/%s">%s</a></td><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>`,
                b.id.value, b.id.value[0..min(8, b.id.value.length)], b.name, b.instanceId.value[0..min(8, b.instanceId.value.length)], b.appId, b.status.to!string);
        sb ~= `</table>` ~ htmlFoot();
        return sb.data;
    }

    private string buildDetailHtml(WebServiceBindingModel model) {
        if (!model.hasSelected) return buildErrorHtml(404, model.errorMessage);
        auto b = model.selected;
        return htmlHead(model.pageTitle) ~ `<h1>` ~ model.pageTitle ~ `</h1><dl>`
            ~ format(`<dt>ID</dt><dd>%s</dd><dt>Name</dt><dd>%s</dd><dt>Instance</dt><dd>%s</dd><dt>App ID</dt><dd>%s</dd><dt>Status</dt><dd>%s</dd><dt>TLS</dt><dd>%s</dd>`,
                b.id.value, b.name, b.instanceId.value, b.appId, b.status.to!string, b.tls ? "yes" : "no")
            ~ `</dl><a href="/web/redis/bindings">Back to list</a>` ~ htmlFoot();
    }

    private string buildErrorHtml(int code, string msg) {
        return htmlHead("Error") ~ `<h1>Error ` ~ code.to!string ~ `</h1><p>` ~ msg ~ `</p><a href="/web/redis/bindings">Back</a>` ~ htmlFoot();
    }

    private string htmlHead(string title) {
        return `<!DOCTYPE html><html><head><meta charset="utf-8"><title>` ~ title ~ ` - Redis on SAP BTP</title>`
            ~ `<style>body{font-family:sans-serif;margin:2em}table{border-collapse:collapse}th,td{padding:6px 12px}.error{color:red}</style></head><body>`;
    }
    private string htmlFoot() { return `</body></html>`; }
}
