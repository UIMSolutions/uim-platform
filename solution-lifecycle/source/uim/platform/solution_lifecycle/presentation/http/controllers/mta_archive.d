/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.solution_lifecycle.presentation.http.controllers.mta_archive;

import uim.platform.solution_lifecycle;

mixin(ShowModule!());

@safe:

/// REST /api/v1/slm/mta-archives — upload, list, get, delete MTA archive files.
class MtaArchiveController : ManageController {
    private ManageMtaArchivesUseCase usecase;

    this(ManageMtaArchivesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/slm/mta-archives",   &handleList);
        router.get("/api/v1/slm/mta-archives/*",  &handleGet);
        router.post("/api/v1/slm/mta-archives",  &handleUpload);
        router.delete_("/api/v1/slm/mta-archives/*", &handleDelete);
    }

    protected void handleUpload(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto data = precheck.data;
            UploadMtaArchiveRequest r;
            r.tenantId     = req.getTenantId;
            r.fileName     = data.getString("fileName");
            r.mtaId        = data.getString("mtaId");
            r.mtaVersion   = data.getString("mtaVersion");
            r.fileSizeBytes = j["fileSizeBytes"].isInteger
                              ? j["fileSizeBytes"].get!long : 0L;
            r.checksum     = data.getString("checksum");
            r.uploadedBy   = data.getString("uploadedBy");
            r.namespace_   = data.getString("namespace");
            if (j["targetPlatforms"].isArray)
                foreach (p; j["targetPlatforms"])
                    r.targetPlatforms ~= p.get!string;

            auto result = usecase.uploadArchive(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(
                    Json.emptyObject.set("id", result.id).set("message", "MTA archive registered"),
                    201
                );
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto archives = usecase.listArchives(tenantId);
            auto arr = Json.emptyArray;
            foreach (a; archives) arr ~= a.toJson;
            res.writeJsonBody(
                Json.emptyObject.set("count", archives.length).set("mta-archives", arr),
                200
            );
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = MtaArchiveId(precheck.id);
            auto a = usecase.getArchive(tenantId, id);
            if (a.isNull) { writeError(res, 404, "MTA archive not found"); return; }
            res.writeJsonBody(a.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = MtaArchiveId(precheck.id);
            auto result = usecase.deleteArchive(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("message", "MTA archive deleted"), 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
