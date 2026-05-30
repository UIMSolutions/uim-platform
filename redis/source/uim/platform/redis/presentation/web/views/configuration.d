/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.web.views.configuration;

import uim.platform.redis;

import std.format : format;

mixin(ShowModule!());

@safe:

class WebConfigurationView {
    void renderList(HTTPServerResponse res, WebConfigurationModel model) @trusted {
        res.writeBody(buildListHtml(model), cast(int) HTTPStatus.ok, "text/html; charset=utf-8");
    }
    void renderDetail(HTTPServerResponse res, WebConfigurationModel model) @trusted {
        int code = model.hasSelected ? cast(int) HTTPStatus.ok : cast(int) HTTPStatus.notFound;
        res.writeBody(buildDetailHtml(model), code, "text/html; charset=utf-8");
    }
    void renderError(HTTPServerResponse res, int code, string msg) @trusted {
        res.writeBody(buildErrorHtml(code, msg), code, "text/html; charset=utf-8");
    }

    private string buildListHtml(WebConfigurationModel model) {
        auto sb = new StringBuilder();
        sb ~= htmlHead(model.pageTitle) ~ `<h1>` ~ model.pageTitle ~ `</h1>`;
        if (model.errorMessage.length > 0) sb ~= `<div class="error">` ~ model.errorMessage ~ `</div>`;
        sb ~= `<table border="1"><tr><th>ID</th><th>Instance</th><th>Eviction</th><th>TLS</th></tr>`;
        foreach (c; model.configurations)
            sb ~= format(`<tr><td><a href="/web/redis/configurations/%s">%s</a></td><td>%s</td><td>%s</td><td>%s</td></tr>`,
                c.id.value, c.id.value[0..min(8, c.id.value.length)], c.instanceId.value[0..min(8, c.instanceId.value.length)],
                c.maxMemoryPolicy.to!string, c.tlsEnabled ? "yes" : "no");
        sb ~= `</table>` ~ htmlFoot();
        return sb.data;
    }

    private string buildDetailHtml(WebConfigurationModel model) {
        if (!model.hasSelected) return buildErrorHtml(404, model.errorMessage);
        auto c = model.selected;
        return htmlHead(model.pageTitle) ~ `<h1>` ~ model.pageTitle ~ `</h1><dl>`
            ~ format(`<dt>ID</dt><dd>%s</dd><dt>Instance</dt><dd>%s</dd><dt>Max Memory Policy</dt><dd>%s</dd><dt>Max Memory MB</dt><dd>%d</dd><dt>Timeout</dt><dd>%d</dd><dt>TLS</dt><dd>%s</dd><dt>Persistence</dt><dd>%s</dd>`,
                c.id.value, c.instanceId.value, c.maxMemoryPolicy.to!string, c.maxMemoryMb, c.timeout_,
                c.tlsEnabled ? "yes" : "no", c.persistenceMode.to!string)
            ~ `</dl><a href="/web/redis/configurations">Back to list</a>` ~ htmlFoot();
    }

    private string buildErrorHtml(int code, string msg) {
        return htmlHead("Error") ~ `<h1>Error ` ~ code.to!string ~ `</h1><p>` ~ msg ~ `</p><a href="/web/redis/configurations">Back</a>` ~ htmlFoot();
    }

    private string htmlHead(string title) {
        return `<!DOCTYPE html><html><head><meta charset="utf-8"><title>` ~ title ~ ` - Redis on SAP BTP</title>`
            ~ `<style>body{font-family:sans-serif;margin:2em}table{border-collapse:collapse}th,td{padding:6px 12px}.error{color:red}</style></head><body>`;
    }
    private string htmlFoot() { return `</body></html>`; }
}
