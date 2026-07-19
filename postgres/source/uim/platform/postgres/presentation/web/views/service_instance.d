/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.web.views.service_instance;

import uim.platform.postgres;
import std.conv   : to;
import std.format : format;
import std.algorithm : min;
mixin(ShowModule!());

@safe:

class WebServiceInstanceView {
    void renderList(HTTPServerResponse res, WebServiceInstanceModel model) @trusted {
        res.writeBody(buildListHtml(model), cast(int) HTTPStatus.ok, "text/html; charset=utf-8");
    }

    void renderDetail(HTTPServerResponse res, WebServiceInstanceModel model) @trusted {
        int code = model.hasSelected ? cast(int) HTTPStatus.ok : cast(int) HTTPStatus.notFound;
        res.writeBody(buildDetailHtml(model), code, "text/html; charset=utf-8");
    }

    void renderError(HTTPServerResponse res, int code, string msg) @trusted {
        res.writeBody(buildErrorHtml(code, msg), code, "text/html; charset=utf-8");
    }

    private string buildListHtml(WebServiceInstanceModel model) {
        auto sb = new StringBuilder();
        sb ~= htmlHead(model.pageTitle);
        sb ~= `<h1>` ~ model.pageTitle ~ `</h1>`;
        if (model.errorMessage.length > 0) sb ~= `<div class="error">` ~ model.errorMessage ~ `</div>`;
        sb ~= `<table border="1"><tr><th>ID</th><th>Name</th><th>Status</th><th>Region</th><th>MemGB</th><th>HA</th></tr>`;
        foreach (i; model.instances)
            sb ~= format(`<tr><td><a href="/web/postgres/instances/%s">%s</a></td><td>%s</td><td>%s</td><td>%s</td><td>%d</td><td>%s</td></tr>`,
                i.id.value, i.id.value[0..min(8, i.id.value.length)], i.name, i.status.to!string, i.region, i.memoryGb, i.multiAz ? "yes" : "no");
        sb ~= `</table>`;
        sb ~= htmlFoot();
        return sb.data;
    }

    private string buildDetailHtml(WebServiceInstanceModel model) {
        if (!model.hasSelected) return buildErrorHtml(404, model.errorMessage);
        auto i  = model.selected;
        auto sb = new StringBuilder();
        sb ~= htmlHead(model.pageTitle);
        sb ~= `<h1>` ~ model.pageTitle ~ `</h1><dl>`;
        sb ~= format(`<dt>ID</dt><dd>%s</dd>`, i.id.value);
        sb ~= format(`<dt>Name</dt><dd>%s</dd>`, i.name);
        sb ~= format(`<dt>Status</dt><dd>%s</dd>`, i.status.to!string);
        sb ~= format(`<dt>Hyperscaler</dt><dd>%s</dd>`, i.hyperscaler.to!string);
        sb ~= format(`<dt>Region</dt><dd>%s</dd>`, i.region);
        sb ~= format(`<dt>Engine</dt><dd>%s</dd>`, i.engineVersion.to!string);
        sb ~= format(`<dt>Memory GB</dt><dd>%d</dd>`, i.memoryGb);
        sb ~= format(`<dt>Storage GB</dt><dd>%d</dd>`, i.storageGb);
        sb ~= format(`<dt>SSL</dt><dd>%s</dd>`, i.sslEnabled ? "yes" : "no");
        sb ~= format(`<dt>Multi-AZ</dt><dd>%s</dd>`, i.multiAz ? "yes" : "no");
        sb ~= `</dl><a href="/web/postgres/instances">Back to list</a>`;
        sb ~= htmlFoot();
        return sb.data;
    }

    private string buildErrorHtml(int code, string msg) {
        return htmlHead("Error " ~ code.to!string)
            ~ `<h1>Error ` ~ code.to!string ~ `</h1><p>` ~ msg ~ `</p>`
            ~ `<a href="/web/postgres/instances">Back to list</a>` ~ htmlFoot();
    }

    private string htmlHead(string title) {
        return `<!DOCTYPE html><html><head><meta charset="utf-8"><title>` ~ title
            ~ ` - PostgreSQL on SAP BTP</title>`
            ~ `<style>body{font-family:sans-serif;margin:2em}table{border-collapse:collapse}th,td{padding:6px 12px}.error{color:red}</style>`
            ~ `</head><body>`;
    }

    private string htmlFoot() { return `</body></html>`; }
}
