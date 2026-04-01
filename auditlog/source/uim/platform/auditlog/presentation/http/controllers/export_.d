module uim.platform.auditlog.presentation.http.controllers.export_;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;
// 
// import uim.platform.auditlog.application.usecases.manage.exports;
// import uim.platform.auditlog.application.dto;
// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.export_job;
// import uim.platform.auditlog.presentation.http.json_utils;

import uim.platform.auditlog;
mixin(ShowModule!());
@safe:
class ExportController {
    private ManageExportsUseCase useCase;

    this(ManageExportsUseCase useCase) {
        this.useCase = useCase;
    }

    override void registerRoutes(URLRouter router) {
        router.post("/api/v1/exports", &handleCreate);
        router.get("/api/v1/exports", &handleList);
        router.get("/api/v1/exports/*", &handleGet);
        router.delete_("/api/v1/exports/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            auto r = CreateExportJobRequest();
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.requestedBy = j.getString("requestedBy");
            r.timeFrom = jsonLong(j, "timeFrom");
            r.timeTo = jsonLong(j, "timeTo");

            auto fmtStr = j.getString("format");
            if (fmtStr == "csv")
                r.format_ = ExportFormat.csv;
            else
                r.format_ = ExportFormat.json;

            // Parse category filter
            auto cats = jsonStrArray(j, "categories");
            foreach (c; cats)
                r.categories ~= parseCategory(c);

            auto result = useCase.createExport(r);
            if (result.isSuccess()) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto jobs = useCase.listExports(tenantId);
            auto arr = Json.emptyArray;
            foreach (ref j; jobs)
                arr ~= serializeJob(j);
            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long)jobs.length);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto id = extractIdFromPath(req.requestURI);
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto job = useCase.getExport(id, tenantId);
            if (job is null) {
                writeError(res, 404, "Export job not found");
                return;
            }
            res.writeJsonBody(serializeJob(job), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto id = extractIdFromPath(req.requestURI);
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            useCase.deleteExport(id, tenantId);
            auto resp = Json.emptyObject;
            resp["status"] = Json("deleted");
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private static Json serializeJob(ref const ExportJob j) {
        auto o = Json.emptyObject;
        o["id"] = Json(j.id);
        o["tenantId"] = Json(j.tenantId);
        o["requestedBy"] = Json(j.requestedBy);
        o["format"] = Json(j.format_.to!string);
        o["status"] = Json(j.status.to!string);
        o["totalRecords"] = Json(j.totalRecords);
        o["downloadUrl"] = Json(j.downloadUrl);
        o["timeFrom"] = Json(j.timeFrom);
        o["timeTo"] = Json(j.timeTo);
        o["createdAt"] = Json(j.createdAt);
        o["completedAt"] = Json(j.completedAt);
        o["errorMessage"] = Json(j.errorMessage);

        if (j.categories.length > 0) {
            auto cats = Json.emptyArray;
            foreach (ref c; j.categories)
                cats ~= Json(categoryToString(c));
            o["categories"] = cats;
        }
        return o;
    }

    private static AuditCategory parseCategory(string s) {
        switch (s) {
        case "audit.security-events", "securityEvents":
            return AuditCategory.securityEvents;
        case "audit.configuration", "configuration":
            return AuditCategory.configuration;
        case "audit.data-access", "dataAccess":
            return AuditCategory.dataAccess;
        case "audit.data-modification", "dataModification":
            return AuditCategory.dataModification;
        default:
            return AuditCategory.securityEvents;
        }
    }

    private static string categoryToString(AuditCategory c) {
        final switch (c) {
        case AuditCategory.securityEvents:
            return "audit.security-events";
        case AuditCategory.configuration:
            return "audit.configuration";
        case AuditCategory.dataAccess:
            return "audit.data-access";
        case AuditCategory.dataModification:
            return "audit.data-modification";
        }
    }
}
