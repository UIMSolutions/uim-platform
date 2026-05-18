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
class MtaArchiveController : PlatformController {
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
            auto j = req.json;
            UploadMtaArchiveRequest r;
            r.tenantId     = req.getTenantId;
            r.fileName     = j.getString("fileName");
            r.mtaId        = j.getString("mtaId");
            r.mtaVersion   = j.getString("mtaVersion");
            r.fileSizeBytes = j["fileSizeBytes"].type == Json.Type.int_
                              ? j["fileSizeBytes"].get!long : 0L;
            r.checksum     = j.getString("checksum");
            r.uploadedBy   = j.getString("uploadedBy");
            r.namespace_   = j.getString("namespace");
            if (j["targetPlatforms"].type == Json.Type.array)
                foreach (p; j["targetPlatforms"])
                    r.targetPlatforms ~= p.get!string;

            auto result = usecase.uploadArchive(r);
            if (result.success) {
                res.writeJsonBody(
                    Json.emptyObject.set("id", result.id).set("message", "MTA archive registered"),
                    201
                );
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
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

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = MtaArchiveId(extractIdFromPath(req.requestURI.to!string));
            auto a = usecase.getArchive(tenantId, id);
            if (a.isNull) { writeError(res, 404, "MTA archive not found"); return; }
            res.writeJsonBody(a.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = MtaArchiveId(extractIdFromPath(req.requestURI.to!string));
            auto result = usecase.deleteArchive(tenantId, id);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("message", "MTA archive deleted"), 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
