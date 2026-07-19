/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.web.views.database_extension;

import uim.platform.postgres;
import std.conv   : to;
import std.format : format;
import std.algorithm : min;
mixin(ShowModule!());

@safe:

class WebDatabaseExtensionView {
    void renderList(HTTPServerResponse res, WebDatabaseExtensionModel model) @trusted {
        res.writeBody(buildListHtml(model), cast(int) HTTPStatus.ok, "text/html; charset=utf-8");
    }

    void renderDetail(HTTPServerResponse res, WebDatabaseExtensionModel model) @trusted {
        int code = model.hasSelected ? cast(int) HTTPStatus.ok : cast(int) HTTPStatus.notFound;
        res.writeBody(buildDetailHtml(model), code, "text/html; charset=utf-8");
    }

    void renderError(HTTPServerResponse res, int code, string msg) @trusted {
        res.writeBody(buildErrorHtml(code, msg), code, "text/html; charset=utf-8");
    }

    private string buildListHtml(WebDatabaseExtensionModel model) {
        auto sb = new StringBuilder();
        sb ~= htmlHead(model.pageTitle);
        sb ~= `<h1>` ~ model.pageTitle ~ `</h1>`;
        if (model.errorMessage.length > 0) sb ~= `<div class="error">` ~ model.errorMessage ~ `</div>`;
        sb ~= `<table border="1"><tr><th>ID</th><th>Extension</th><th>Version</th><th>Status</th></tr>`;
        foreach (e; model.extensions)
            sb ~= format(`<tr><td><a href="/web/postgres/extensions/%s">%s</a></td><td>%s</td><td>%s</td><td>%s</td></tr>`,
                e.id.value, e.id.value[0..min(8, e.id.value.length)], e.extensionName, e.extensionVersion, e.status.to!string);
        sb ~= `</table>` ~ htmlFoot();
        return sb.data;
    }

    private string buildDetailHtml(WebDatabaseExtensionModel model) {
        if (!model.hasSelected) return buildErrorHtml(404, model.errorMessage);
        auto e  = model.selected;
        auto sb = new StringBuilder();
        sb ~= htmlHead(model.pageTitle);
        sb ~= `<h1>` ~ model.pageTitle ~ `</h1><dl>`;
        sb ~= format(`<dt>ID</dt><dd>%s</dd>`, e.id.value);
        sb ~= format(`<dt>Instance ID</dt><dd>%s</dd>`, e.instanceId.value);
        sb ~= format(`<dt>Extension Name</dt><dd>%s</dd>`, e.extensionName);
        sb ~= format(`<dt>Extension Version</dt><dd>%s</dd>`, e.extensionVersion);
        sb ~= format(`<dt>Schema</dt><dd>%s</dd>`, e.schema_);
        sb ~= format(`<dt>Status</dt><dd>%s</dd>`, e.status.to!string);
        sb ~= `</dl><a href="/web/postgres/extensions">Back to list</a>` ~ htmlFoot();
        return sb.data;
    }

    private string buildErrorHtml(int code, string msg) {
        return htmlHead("Error " ~ code.to!string)
            ~ `<h1>Error ` ~ code.to!string ~ `</h1><p>` ~ msg ~ `</p>`
            ~ `<a href="/web/postgres/extensions">Back to list</a>` ~ htmlFoot();
    }

    private string htmlHead(string title) {
        return `<!DOCTYPE html><html><head><meta charset="utf-8"><title>` ~ title
            ~ ` - PostgreSQL on SAP BTP</title>`
            ~ `<style>body{font-family:sans-serif;margin:2em}table{border-collapse:collapse}th,td{padding:6px 12px}.error{color:red}</style>`
            ~ `</head><body>`;
    }

    private string htmlFoot() { return `</body></html>`; }
}
