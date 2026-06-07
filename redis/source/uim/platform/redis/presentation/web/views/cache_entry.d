/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.web.views.cache_entry;

import uim.platform.redis;

import std.format : format;

// mixin(ShowModule!());

@safe:

class WebCacheEntryView {
    void renderList(HTTPServerResponse res, WebCacheEntryModel model) @trusted {
        res.writeBody(buildListHtml(model), cast(int) HTTPStatus.ok, "text/html; charset=utf-8");
    }
    void renderDetail(HTTPServerResponse res, WebCacheEntryModel model) @trusted {
        int code = model.hasSelected ? cast(int) HTTPStatus.ok : cast(int) HTTPStatus.notFound;
        res.writeBody(buildDetailHtml(model), code, "text/html; charset=utf-8");
    }
    void renderError(HTTPServerResponse res, int code, string msg) @trusted {
        res.writeBody(buildErrorHtml(code, msg), code, "text/html; charset=utf-8");
    }

    private string buildListHtml(WebCacheEntryModel model) {
        auto sb = new StringBuilder();
        sb ~= htmlHead(model.pageTitle) ~ `<h1>` ~ model.pageTitle ~ `</h1>`;
        if (model.errorMessage.length > 0) sb ~= `<div class="error">` ~ model.errorMessage ~ `</div>`;
        sb ~= `<table border="1"><tr><th>ID</th><th>Key</th><th>Type</th><th>TTL</th></tr>`;
        foreach (e; model.entries)
            sb ~= format(`<tr><td><a href="/web/redis/cache-entries/%s">%s</a></td><td>%s</td><td>%s</td><td>%s</td></tr>`,
                e.id.value, e.id.value[0..min(8, e.id.value.length)], e.key, e.entryType.to!string,
                e.ttl < 0 ? "no expiry" : e.ttl.to!string ~ "s");
        sb ~= `</table>` ~ htmlFoot();
        return sb.data;
    }

    private string buildDetailHtml(WebCacheEntryModel model) {
        if (!model.hasSelected) return buildErrorHtml(404, model.errorMessage);
        auto e = model.selected;
        string truncValue = e.value.length > 200 ? e.value[0..200] ~ "..." : e.value;
        return htmlHead(model.pageTitle) ~ `<h1>` ~ model.pageTitle ~ `</h1><dl>`
            ~ format(`<dt>ID</dt><dd>%s</dd><dt>Key</dt><dd>%s</dd><dt>Type</dt><dd>%s</dd><dt>TTL</dt><dd>%s</dd><dt>Value</dt><dd><pre>%s</pre></dd>`,
                e.id.value, e.key, e.entryType.to!string, e.ttl < 0 ? "no expiry" : e.ttl.to!string ~ "s", truncValue)
            ~ `</dl><a href="/web/redis/cache-entries">Back to list</a>` ~ htmlFoot();
    }

    private string buildErrorHtml(int code, string msg) {
        return htmlHead("Error") ~ `<h1>Error ` ~ code.to!string ~ `</h1><p>` ~ msg ~ `</p><a href="/web/redis/cache-entries">Back</a>` ~ htmlFoot();
    }

    private string htmlHead(string title) {
        return `<!DOCTYPE html><html><head><meta charset="utf-8"><title>` ~ title ~ ` - Redis on SAP BTP</title>`
            ~ `<style>body{font-family:sans-serif;margin:2em}table{border-collapse:collapse}th,td{padding:6px 12px}.error{color:red}</style></head><body>`;
    }
    private string htmlFoot() { return `</body></html>`; }
}
