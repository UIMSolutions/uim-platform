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
        auto jarr = items.map!(e => e.toJson()).array.toJson;
        auto resp = Json.emptyObject
            .set("count", items.length)
            .set("resources", jarr);

        return successResponse("Deployment list retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;

        DeploymentDTO dto;
        dto.deploymentId = DeploymentId(j.getString("id"));
        dto.mobileApplicationId = MobileApplicationId(j.getString("mobileApplicationId"));
        dto.appVersionId = AppVersionId(j.getString("appVersionId"));
        dto.tenantId = tenantId;
        dto.scope_ = j.getString("scope");
        dto.targetDeviceId = j.getString("targetDeviceId");
        dto.targetGroupName = j.getString("targetGroupName");
        dto.scheduledAt = j.getString("scheduledAt");
        dto.deployedBy = j.getString("deployedBy");
        dto.notes = j.getString("notes");

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

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto j = req.json;
            DeploymentDTO dto;
            dto.deploymentId = DeploymentId(precheck.id);
            dto.tenantId = tenantId;
            dto.notes = j.getString("notes");
            dto.scheduledAt = j.getString("scheduledAt");

            auto result = usecase.updateDeployment(dto);
            if (!result.success) {
                writeError(res, 404, result.message);
                return;
            }

            auto resp = Json.emptyObject
                .set("id", result.id)
                .set("message", "Deployment updated successfully");
            res.writeJsonBody(resp, 200);
        
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = DeploymentId(precheck.id);
            auto result = usecase.deleteDeployment(tenantId, id);
            if (!result.success) {
                writeError(res, 404, result.message);
                return;
            }
            res.writeJsonBody(Json.emptyObject.set("message", "Deployment deleted successfully"), 200);
        
    }
}
