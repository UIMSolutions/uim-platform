/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.web.views.backup_policy;

import uim.platform.redis;

import std.format : format;
mixin(ShowModule!());

@safe:

class WebBackupPolicyView {
    void renderList(HTTPServerResponse res, WebBackupPolicyModel model) @trusted {
        res.writeBody(buildListHtml(model), cast(int) HTTPStatus.ok, "text/html; charset=utf-8");
    }
    void renderDetail(HTTPServerResponse res, WebBackupPolicyModel model) @trusted {
        int code = model.hasSelected ? cast(int) HTTPStatus.ok : cast(int) HTTPStatus.notFound;
        res.writeBody(buildDetailHtml(model), code, "text/html; charset=utf-8");
    }
    void renderError(HTTPServerResponse res, int code, string msg) @trusted {
        res.writeBody(buildErrorHtml(code, msg), code, "text/html; charset=utf-8");
    }

    private string buildListHtml(WebBackupPolicyModel model) {
        auto sb = new StringBuilder();
        sb ~= htmlHead(model.pageTitle) ~ `<h1>` ~ model.pageTitle ~ `</h1>`;
        sb ~= `<table border="1"><tr><th>ID</th><th>Schedule</th><th>Retention</th><th>Status</th></tr>`;
        foreach (p; model.policies)
            sb ~= format(`<tr><td><a href="/web/redis/backup-policies/%s">%s</a></td><td>%s</td><td>%d days</td><td>%s</td></tr>`,
                p.id.value, p.id.value[0..min(8, p.id.value.length)], p.schedule, p.retentionDays, p.status.to!string);
        sb ~= `</table>` ~ htmlFoot();
        return sb.data;
    }

    private string buildDetailHtml(WebBackupPolicyModel model) {
        if (!model.hasSelected) return buildErrorHtml(404, model.errorMessage);
        auto p = model.selected;
        return htmlHead(model.pageTitle) ~ `<h1>` ~ model.pageTitle ~ `</h1><dl>`
            ~ format(`<dt>ID</dt><dd>%s</dd><dt>Schedule</dt><dd>%s</dd><dt>Retention Days</dt><dd>%d</dd><dt>Storage Location</dt><dd>%s</dd><dt>Status</dt><dd>%s</dd>`,
                p.id.value, p.schedule, p.retentionDays, p.storageLocation, p.status.to!string)
            ~ `</dl><a href="/web/redis/backup-policies">Back to list</a>` ~ htmlFoot();
    }

    private string buildErrorHtml(int code, string msg) {
        return htmlHead("Error") ~ `<h1>Error ` ~ code.to!string ~ `</h1><p>` ~ msg ~ `</p><a href="/web/redis/backup-policies">Back</a>` ~ htmlFoot();
    }

    private string htmlHead(string title) {
        return `<!DOCTYPE html><html><head><meta charset="utf-8"><title>` ~ title ~ ` - Redis on SAP BTP</title>`
            ~ `<style>body{font-family:sans-serif;margin:2em}table{border-collapse:collapse}th,td{padding:6px 12px}.error{color:red}</style></head><body>`;
    }
    private string htmlFoot() { return `</body></html>`; }
}
