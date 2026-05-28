/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.presentation.http.controllers.deployment;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class DeploymentController : ManageController {
    private ManageDeploymentsUseCase usecase;

    this(ManageDeploymentsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/agentry/deployments", &handleList);
        router.get("/api/v1/agentry/deployments/*", &handleGet);
        router.post("/api/v1/agentry/deployments", &handleCreate);
        router.put("/api/v1/agentry/deployments/*", &handleUpdate);
        router.delete_("/api/v1/agentry/deployments/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listDeployments(tenantId);
        auto list = items.map!(e => e.toJson()).array.toJson;
        auto resp = Json.emptyObject
            .set("count", items.length)
            .set("resources", list);

        return successResponse("Deployment list retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        DeploymentDTO dto;
        dto.deploymentId = DeploymentId(precheck.id);
        dto.mobileApplicationId = MobileApplicationId(data.getString("mobileApplicationId"));
        dto.appVersionId = AppVersionId(data.getString("appVersionId"));
        dto.tenantId = tenantId;
        dto.scope_ = data.getString("scope");
        dto.targetDeviceId = data.getString("targetDeviceId");
        dto.targetGroupName = data.getString("targetGroupName");
        dto.scheduledAt = data.getLong("scheduledAt");
        dto.deployedBy = data.getString("deployedBy");
        dto.notes = data.getString("notes");

        auto result = usecase.createDeployment(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject
            .set("id", result.id);

        return successResponse("Deployment created successfully", "Created", 201, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;

        auto id = DeploymentId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid deployment ID", 400);

        auto e = usecase.getDeployment(tenantId, id);
        if (job.isNull)
            return errorResponse("Deployment not found", 404);

        auto responseData = job.toJson();

        return successResponse("Deployment retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = DeploymentId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid deployment ID", 400);

        DeploymentDTO dto;
        dto.deploymentId = id;
        dto.tenantId = tenantId;
        dto.notes = data.getString("notes");
        dto.scheduledAt = data.getLong("scheduledAt");

        auto result = usecase.updateDeployment(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Deployment updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = DeploymentId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid deployment ID", 400);

        auto result = usecase.deleteDeployment(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Deployment deleted successfully", "Deleted", 200, responseData);
    }
}
