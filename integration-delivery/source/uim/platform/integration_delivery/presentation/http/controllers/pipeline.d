/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.presentation.http.controllers.pipeline;

import uim.platform.integration_delivery;

// mixin(ShowModule!());

@safe:

class PipelineController : ManageHttpController {
    private ManagePipelinesUseCase pipelines;

    this(ManagePipelinesUseCase pipelines) {
        this.pipelines = pipelines;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/integration-delivery/pipelines", &handleList);
        router.get("/api/v1/integration-delivery/pipelines/*", &handleGet);
        router.post("/api/v1/integration-delivery/pipelines", &handleCreate);
        router.put("/api/v1/integration-delivery/pipelines/*", &handleUpdate);
        router.delete_("/api/v1/integration-delivery/pipelines/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto items = pipelines.listPipelines(tenantId);
        return Json.emptyObject
            .set("count", items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson)
            .set("message", "Pipelines retrieved successfully")
            .set("status", "success")
            .set("statusCode", 200);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = PipelineId(precheck.id);
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid pipeline ID").set("statusCode", 400);

        auto e = pipelines.getPipeline(tenantId, id);
        if (e.isNull)
            return Json.emptyObject.set("error", "Pipeline not found").set("statusCode", 404);

        return e.toJson().set("message", "Pipeline retrieved successfully").set("status", "success").set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        PipelineDTO dto;
        dto.pipelineId = PipelineId(data.getString("pipelineId", ""));
        dto.tenantId = tenantId;
        dto.name = data.getString("name", "");
        dto.description = data.getString("description", "");
        dto.configurationYaml = data.getString("configurationYaml", "");
        dto.version_ = data.getString("version", "");
        dto.createdBy = UserId(data.getString("createdBy", ""));

        auto result = pipelines.createPipeline(dto);
        if (result.hasError)
            return Json.emptyObject.set("error", result.message).set("statusCode", 400);

        return Json.emptyObject.set("id", result.id).set("message", "Pipeline created").set("status", "created").set("statusCode", 201);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        auto id = PipelineId(precheck.id);
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid pipeline ID").set("statusCode", 400);

        PipelineDTO dto;
        dto.tenantId = tenantId;
        dto.pipelineId = id;
        dto.name = data.getString("name", "");
        dto.description = data.getString("description", "");
        dto.configurationYaml = data.getString("configurationYaml", "");
        dto.updatedBy = UserId(data.getString("updatedBy", ""));

        auto result = pipelines.updatePipeline(dto);
        if (result.hasError)
            return Json.emptyObject.set("error", result.message).set("statusCode", 400);

        return Json.emptyObject.set("id", result.id).set("message", "Pipeline updated").set("status", "updated").set("statusCode", 200);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = PipelineId(precheck.id);
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid pipeline ID").set("statusCode", 400);

        auto result = pipelines.deletePipeline(tenantId, id);
        if (result.hasError)
            return Json.emptyObject.set("error", result.message).set("statusCode", 400);

        return Json.emptyObject.set("id", result.id).set("message", "Pipeline deleted").set("status", "deleted").set("statusCode", 200);
    }
}
