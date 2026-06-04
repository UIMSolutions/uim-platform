/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.presentation.http.controllers.deployment_target;

import uim.platform.integration_delivery;

mixin(ShowModule!());

@safe:

class DeploymentTargetController : ManageHttpController {
    private ManageDeploymentTargetsUseCase targets;

    this(ManageDeploymentTargetsUseCase targets) {
        this.targets = targets;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/integration-delivery/deployment-targets", &handleList);
        router.get("/api/v1/integration-delivery/deployment-targets/*", &handleGet);
        router.post("/api/v1/integration-delivery/deployment-targets", &handleCreate);
        router.put("/api/v1/integration-delivery/deployment-targets/*", &handleUpdate);
        router.delete_("/api/v1/integration-delivery/deployment-targets/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto items = targets.listDeploymentTargets(tenantId);
        return Json.emptyObject
            .set("count", items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson)
            .set("message", "Deployment targets retrieved successfully")
            .set("status", "success")
            .set("statusCode", 200);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = DeploymentTargetId(precheck.id);
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid deployment target ID").set("statusCode", 400);

        auto e = targets.getDeploymentTarget(tenantId, id);
        if (e.isNull)
            return Json.emptyObject.set("error", "Deployment target not found").set("statusCode", 404);

        return e.toJson().set("message", "Deployment target retrieved successfully").set("status", "success").set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        DeploymentTargetDTO dto;
        dto.deploymentTargetId = DeploymentTargetId(data.getString("deploymentTargetId", ""));
        dto.tenantId = precheck.tenantId;
        dto.name = data.getString("name", "");
        dto.description = data.getString("description", "");
        dto.url = data.getString("url", "");
        dto.organization = data.getString("organization", "");
        dto.spaceOrNamespace = data.getString("spaceOrNamespace", "");
        dto.region = data.getString("region", "");
        dto.createdBy = UserId(data.getString("createdBy", ""));

        auto result = targets.createDeploymentTarget(dto);
        if (result.hasError)
            return Json.emptyObject.set("error", result.message).set("statusCode", 400);

        return Json.emptyObject.set("id", result.id).set("message", "Deployment target created").set("status", "created").set("statusCode", 201);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        auto id = DeploymentTargetId(precheck.id);
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid deployment target ID").set("statusCode", 400);

        DeploymentTargetDTO dto;
        dto.tenantId = precheck.tenantId;
        dto.deploymentTargetId = id;
        dto.name = data.getString("name", "");
        dto.description = data.getString("description", "");
        dto.url = data.getString("url", "");
        dto.organization = data.getString("organization", "");
        dto.spaceOrNamespace = data.getString("spaceOrNamespace", "");
        dto.region = data.getString("region", "");
        dto.updatedBy = UserId(data.getString("updatedBy", ""));

        auto result = targets.updateDeploymentTarget(dto);
        if (result.hasError)
            return Json.emptyObject.set("error", result.message).set("statusCode", 400);

        return Json.emptyObject.set("id", result.id).set("message", "Deployment target updated").set("status", "updated").set("statusCode", 200);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = DeploymentTargetId(precheck.id);
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid deployment target ID").set("statusCode", 400);

        auto result = targets.deleteDeploymentTarget(tenantId, id);
        if (result.hasError)
            return Json.emptyObject.set("error", result.message).set("statusCode", 400);

        return Json.emptyObject.set("id", result.id).set("message", "Deployment target deleted").set("status", "deleted").set("statusCode", 200);
    }
}
