/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.presentation.http.controllers.build;

import uim.platform.integration_delivery;

mixin(ShowModule!());

@safe:

class BuildController : ManageController {
    private ManageBuildsUseCase builds;

    this(ManageBuildsUseCase builds) {
        this.builds = builds;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/integration-delivery/builds", &handleList);
        router.get("/api/v1/integration-delivery/builds/*", &handleGet);
        router.post("/api/v1/integration-delivery/builds", &handleCreate);
        router.put("/api/v1/integration-delivery/builds/*", &handleUpdate);
        router.delete_("/api/v1/integration-delivery/builds/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (!precheck.success)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = TenantId(precheck.gString("tenantId"));
        auto items = builds.listBuilds(tenantId);
        return Json.emptyObject
            .set("count", items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson)
            .set("message", "Builds retrieved successfully")
            .set("status", "success")
            .set("statusCode", 200);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (!precheck.success)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = TenantId(precheck.gString("tenantId"));
        auto id = BuildId(extractIdFromPath(req.requestURI.to!string));
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid build ID").set("statusCode", 400);

        auto e = builds.getBuild(tenantId, id);
        if (e.isNull)
            return Json.emptyObject.set("error", "Build not found").set("statusCode", 404);

        return e.toJson().set("message", "Build retrieved successfully").set("status", "success").set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (!precheck.success)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = TenantId(precheck.gString("tenantId"));
        auto data = precheck["data"];

        BuildDTO dto;
        dto.buildId = BuildId(data.getString("buildId", ""));
        dto.tenantId = tenantId;
        dto.commitSha = data.getString("commitSha", "");
        dto.branch = data.getString("branch", "");
        dto.commitMessage = data.getString("commitMessage", "");
        dto.commitAuthor = data.getString("commitAuthor", "");
        dto.triggerInfo = data.getString("triggerInfo", "");
        dto.createdBy = UserId(data.getString("createdBy", ""));

        auto result = builds.triggerBuild(dto);
        if (result.failure)
            return Json.emptyObject.set("error", result.error).set("statusCode", 400);

        return Json.emptyObject.set("id", result.id).set("message", "Build triggered").set("status", "created").set("statusCode", 201);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (!precheck.success)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = TenantId(precheck.gString("tenantId"));
        auto data = precheck["data"];
        auto id = BuildId(extractIdFromPath(req.requestURI.to!string));
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid build ID").set("statusCode", 400);

        auto errorMessage = data.getString("errorMessage", "");
        auto result = builds.updateBuildStatus(tenantId, id, BuildStatus.running, errorMessage);
        if (result.failure)
            return Json.emptyObject.set("error", result.error).set("statusCode", 400);

        return Json.emptyObject.set("id", result.id).set("message", "Build updated").set("status", "updated").set("statusCode", 200);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (!precheck.success)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = TenantId(precheck.gString("tenantId"));
        auto id = BuildId(extractIdFromPath(req.requestURI.to!string));
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid build ID").set("statusCode", 400);

        auto result = builds.deleteBuild(tenantId, id);
        if (result.failure)
            return Json.emptyObject.set("error", result.error).set("statusCode", 400);

        return Json.emptyObject.set("id", result.id).set("message", "Build deleted").set("status", "deleted").set("statusCode", 200);
    }
}
