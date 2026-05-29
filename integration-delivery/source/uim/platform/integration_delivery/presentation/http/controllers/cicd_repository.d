/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.presentation.http.controllers.cicd_repository;

import uim.platform.integration_delivery;

mixin(ShowModule!());

@safe:

class CicdRepositoryController : ManageController {
    private ManageCicdRepositoriesUseCase repos;

    this(ManageCicdRepositoriesUseCase repos) {
        this.repos = repos;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/integration-delivery/repositories", &handleList);
        router.get("/api/v1/integration-delivery/repositories/*", &handleGet);
        router.post("/api/v1/integration-delivery/repositories", &handleCreate);
        router.put("/api/v1/integration-delivery/repositories/*", &handleUpdate);
        router.delete_("/api/v1/integration-delivery/repositories/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = precheck.tenantId;
        auto items = repos.listCicdRepositories(tenantId);
        return Json.emptyObject
            .set("count", items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson)
            .set("message", "Repositories retrieved successfully")
            .set("status", "success")
            .set("statusCode", 200);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = precheck.tenantId;
        auto id = CicdRepositoryId(precheck.id);
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid repository ID").set("statusCode", 400);

        auto e = repos.getCicdRepository(tenantId, id);
        if (e.isNull)
            return Json.emptyObject.set("error", "Repository not found").set("statusCode", 404);

        return e.toJson().set("message", "Repository retrieved successfully").set("status", "success").set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        CicdRepositoryDTO dto;
        dto.cicdRepositoryId = CicdRepositoryId(data.getString("cicdRepositoryId", ""));
        dto.tenantId = tenantId;
        dto.name = data.getString("name", "");
        dto.description = data.getString("description", "");
        dto.url = data.getString("url", "");
        dto.defaultBranch = data.getString("defaultBranch", "main");
        dto.webhookEnabled = data.gBool("webhookEnabled");
        dto.createdBy = UserId(data.getString("createdBy", ""));

        auto result = repos.createCicdRepository(dto);
        if (result.hasError)
            return Json.emptyObject.set("error", result.message).set("statusCode", 400);

        return Json.emptyObject.set("id", result.id).set("message", "Repository created").set("status", "created").set("statusCode", 201);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        auto id = CicdRepositoryId(precheck.id);
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid repository ID").set("statusCode", 400);

        CicdRepositoryDTO dto;
        dto.tenantId = tenantId;
        dto.cicdRepositoryId = id;
        dto.name = data.getString("name", "");
        dto.description = data.getString("description", "");
        dto.url = data.getString("url", "");
        dto.defaultBranch = data.getString("defaultBranch", "");
        dto.updatedBy = UserId(data.getString("updatedBy", ""));

        auto result = repos.updateCicdRepository(dto);
        if (result.hasError)
            return Json.emptyObject.set("error", result.message).set("statusCode", 400);

        return Json.emptyObject.set("id", result.id).set("message", "Repository updated").set("status", "updated").set("statusCode", 200);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = precheck.tenantId;
        auto id = CicdRepositoryId(precheck.id);
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid repository ID").set("statusCode", 400);

        auto result = repos.deleteCicdRepository(tenantId, id);
        if (result.hasError)
            return Json.emptyObject.set("error", result.message).set("statusCode", 400);

        return Json.emptyObject.set("id", result.id).set("message", "Repository deleted").set("status", "deleted").set("statusCode", 200);
    }
}
