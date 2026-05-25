/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.presentation.http.controllers.deployment;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class DeploymentController : PlatformController {
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

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto items = usecase.listDeployments(tenantId);
            auto jarr = items.map!(e => e.toJson()).array.toJson;
            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr)
                .set("message", "Deployment list retrieved successfully");
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = DeploymentId(extractIdFromPath(path));
            auto e = usecase.getDeployment(tenantId, id);
            if (e.isNull) { writeError(res, 404, "Deployment not found"); return; }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
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
            if (!result.success) { writeError(res, 400, result.message); return; }

            auto resp = Json.emptyObject
                .set("id", result.id)
                .set("message", "Deployment created successfully");
            res.writeJsonBody(resp, 201);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto j = req.json;
            DeploymentDTO dto;
            dto.deploymentId = DeploymentId(extractIdFromPath(path));
            dto.tenantId = tenantId;
            dto.notes = j.getString("notes");
            dto.scheduledAt = j.getString("scheduledAt");

            auto result = usecase.updateDeployment(dto);
            if (!result.success) { writeError(res, 404, result.message); return; }

            auto resp = Json.emptyObject
                .set("id", result.id)
                .set("message", "Deployment updated successfully");
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = DeploymentId(extractIdFromPath(path));
            auto result = usecase.deleteDeployment(tenantId, id);
            if (!result.success) { writeError(res, 404, result.message); return; }
            res.writeJsonBody(Json.emptyObject.set("message", "Deployment deleted successfully"), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
