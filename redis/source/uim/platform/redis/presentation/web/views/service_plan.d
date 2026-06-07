/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.web.views.service_plan;

import uim.platform.redis;

import std.format : format;

// mixin(ShowModule!());

@safe:

class WebServicePlanView {
    void renderList(HTTPServerResponse res, WebServicePlanModel model) @trusted {
        res.writeBody(buildListHtml(model), cast(int) HTTPStatus.ok, "text/html; charset=utf-8");
    }
    void renderDetail(HTTPServerResponse res, WebServicePlanModel model) @trusted {
        int code = model.hasSelected ? cast(int) HTTPStatus.ok : cast(int) HTTPStatus.notFound;
        res.writeBody(buildDetailHtml(model), code, "text/html; charset=utf-8");
    }
    void renderError(HTTPServerResponse res, int code, string msg) @trusted {
        res.writeBody(buildErrorHtml(code, msg), code, "text/html; charset=utf-8");
    }

    private string buildListHtml(WebServicePlanModel model) {
        auto sb = new StringBuilder();
        sb ~= htmlHead(model.pageTitle) ~ `<h1>` ~ model.pageTitle ~ `</h1>`;
        if (model.errorMessage.length > 0) sb ~= `<div class="error">` ~ model.errorMessage ~ `</div>`;
        sb ~= `<table border="1"><tr><th>ID</th><th>Name</th><th>Tier</th><th>Memory</th><th>HA</th><th>Available</th></tr>`;
        foreach (p; model.plans)
            sb ~= format(`<tr><td><a href="/web/redis/plans/%s">%s</a></td><td>%s</td><td>%s</td><td>%dMB</td><td>%s</td><td>%s</td></tr>`,
                p.id.value, p.id.value[0..min(8, p.id.value.length)], p.name, p.tier.to!string, p.memoryMb, p.haEnabled ? "yes" : "no", p.available ? "yes" : "no");
        sb ~= `</table>` ~ htmlFoot();
        return sb.data;
    }

    private string buildDetailHtml(WebServicePlanModel model) {
        if (!model.hasSelected) return buildErrorHtml(404, model.errorMessage);
        auto p = model.selected;
        return htmlHead(model.pageTitle) ~ `<h1>` ~ model.pageTitle ~ `</h1><dl>`
            ~ format(`<dt>ID</dt><dd>%s</dd><dt>Name</dt><dd>%s</dd><dt>Tier</dt><dd>%s</dd><dt>Memory MB</dt><dd>%d</dd><dt>Max Connections</dt><dd>%d</dd><dt>HA</dt><dd>%s</dd><dt>Persistence</dt><dd>%s</dd><dt>Available</dt><dd>%s</dd>`,
                p.id.value, p.name, p.tier.to!string, p.memoryMb, p.maxConnections,
                p.haEnabled ? "yes" : "no", p.persistenceEnabled ? "yes" : "no", p.available ? "yes" : "no")
            ~ `</dl><a href="/web/redis/plans">Back to list</a>` ~ htmlFoot();
    }

    private string buildErrorHtml(int code, string msg) {
        return htmlHead("Error") ~ `<h1>Error ` ~ code.to!string ~ `</h1><p>` ~ msg ~ `</p><a href="/web/redis/plans">Back</a>` ~ htmlFoot();
    }

    private string htmlHead(string title) {
        return `<!DOCTYPE html><html><head><meta charset="utf-8"><title>` ~ title ~ ` - Redis on SAP BTP</title>`
            ~ `<style>body{font-family:sans-serif;margin:2em}table{border-collapse:collapse}th,td{padding:6px 12px}.error{color:red}</style></head><body>`;
    }
    private string htmlFoot() { return `</body></html>`; }
}
