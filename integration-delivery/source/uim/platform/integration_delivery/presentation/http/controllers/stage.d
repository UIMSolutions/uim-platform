/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.presentation.http.controllers.stage;

import uim.platform.integration_delivery;

// mixin(ShowModule!());

@safe:

class StageController : ManageHttpController {
    private ManageStagesUseCase stages;

    this(ManageStagesUseCase stages) {
        this.stages = stages;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/integration-delivery/stages", &handleList);
        router.get("/api/v1/integration-delivery/stages/*", &handleGet);
        router.post("/api/v1/integration-delivery/stages", &handleCreate);
        router.put("/api/v1/integration-delivery/stages/*", &handleUpdate);
        router.delete_("/api/v1/integration-delivery/stages/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto items = stages.listStages(tenantId);
        return Json.emptyObject
            .set("count", items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson)
            .set("message", "Stages retrieved successfully")
            .set("status", "success")
            .set("statusCode", 200);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = StageId(precheck.id);
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid stage ID").set("statusCode", 400);

        auto e = stages.getStage(tenantId, id);
        if (e.isNull)
            return Json.emptyObject.set("error", "Stage not found").set("statusCode", 404);

        return e.toJson().set("message", "Stage retrieved successfully").set("status", "success").set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        StageDTO dto;
        dto.stageId = StageId(data.getString("stageId", ""));
        dto.tenantId = tenantId;
        dto.name = data.getString("name", "");
        dto.order_ = cast(int) data.gLong("order_");
        dto.isOptional = data.gBool("isOptional");
        dto.createdBy = UserId(data.getString("createdBy", ""));

        auto result = stages.createStage(dto);
        if (result.hasError)
            return Json.emptyObject.set("error", result.message).set("statusCode", 400);

        return Json.emptyObject.set("id", result.id).set("message", "Stage created").set("status", "created").set("statusCode", 201);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        auto id = StageId(precheck.id);
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid stage ID").set("statusCode", 400);

        StageDTO dto;
        dto.tenantId = tenantId;
        dto.stageId = id;
        dto.name = data.getString("name", "");
        dto.updatedBy = UserId(data.getString("updatedBy", ""));

        auto result = stages.updateStage(dto);
        if (result.hasError)
            return errorResponse(result.message, 400); 

        return successResponse("Stage updated successfully", "Updated", 200, Json.emptyObject.set("id", result.id));
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = StageId(precheck.id);
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid stage ID").set("statusCode", 400);

        auto result = stages.deleteStage(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        return successResponse("Stage deleted successfully", "Deleted", 200, Json.emptyObject.set("id", result.id));
    }
}
