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
class MtaArchiveController : ManageHttpController {
    private ManageMtaArchivesUseCase usecase;

    this(ManageMtaArchivesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/slm/mta-archives", &handleList);
        router.get("/api/v1/slm/mta-archives/*", &handleGet);
        router.post("/api/v1/slm/mta-archives", &handleUpload);
        router.delete_("/api/v1/slm/mta-archives/*", &handleDelete);
    }

    override protected Json uploadHandler(HTTPServerRequest req) {
        auto precheck = super.uploadHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
            UploadMtaArchiveRequest r;
            r.tenantId = tenantId;
            r.fileName = data.getString("fileName");
            r.mtaId = data.getString("mtaId");
            r.mtaVersion = data.getString("mtaVersion");
            r.fileSizeBytes = data.get("fileSizeBytes", 0L).get!long;
            r.checksum = data.getString("checksum");
            r.uploadedBy = data.getString("uploadedBy");
            r.namespace_ = data.getString("namespace");
            if (data.get("targetPlatforms", Json.emptyArray).isArray)
                foreach (p; data.get("targetPlatforms", Json.emptyArray))
                    r.targetPlatforms ~= p.get!string;

            auto result = usecase.uploadArchive(r);
            if (result.hasError)
                return errorResponse(result.message, 400);
            
}
    mixin(HandleTemplate!("handleUpload", "uploadHandler"));

override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
        return precheck;

    auto tenantId = precheck.tenantId;

    auto archives = usecase.listArchives(tenantId).map!(a => a.toJson()).array.toJson;
    return successResponse("MTA archives retrieved successfully", "Retrieved", 200,
        Json.emptyObject.set("count", archives.length).set("mta-archives", archives));
}

override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
        return precheck;

    auto tenantId = precheck.tenantId;
    auto id = MtaArchiveId(precheck.id);
    if (id.isNull)
        return errorResponse("Invalid MTA archive ID", 400);

    auto a = usecase.getArchive(tenantId, id);
    if (a.isNull)
        return errorResponse("MTA archive not found", 404);

    return successResponse("MTA archive retrieved successfully", "Retrieved", 200, a.toJson());
}

override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
        return precheck;

    auto tenantId = precheck.tenantId;
    auto id = MtaArchiveId(precheck.id);
    if (id.isNull)
        return errorResponse("Invalid MTA archive ID", 400);

    // writeError(res, 400, "Invalid MTA archive ID"); return; }
    auto result = usecase.deleteArchive(tenantId, id);
    if (result.hasError)
        return errorResponse(result.message, 400);

    return successResponse("MTA archive deleted successfully", "Deleted", 200, Json
            .emptyObject.set("id", id.value));
    //     res.writeJsonBody(Json.emptyObject.set("message", "MTA archive deleted"), 200);
    // } else {
    //     writeError(res, 404, result.message);
}
}
