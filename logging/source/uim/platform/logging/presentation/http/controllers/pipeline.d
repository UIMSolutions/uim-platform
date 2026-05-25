/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.presentation.http.controllers.pipeline;
// import uim.platform.logging.application.usecases.manage.pipelines;
// import uim.platform.logging.application.dto;

import uim.platform.logging;

mixin(ShowModule!());

@safe:

class PipelineController : ManageController {
  private ManagePipelinesUseCase usecase;

  this(ManagePipelinesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/pipelines", &handleCreate);
    router.get("/api/v1/pipelines", &handleList);
    router.get("/api/v1/pipelines/*", &handleGet);
    router.put("/api/v1/pipelines/*", &handleUpdate);
    router.delete_("/api/v1/pipelines/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreatePipelineRequest r;
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.sourceType = j.getString("sourceType");
      r.format = j.getString("format");
      r.targetStreamId = j.getString("targetStreamId");
      r.createdBy = UserId(j.getString("createdBy"));

      foreach (pj; j.getArray("processors")) {
        ProcessorDTO p;
        p.type = getString(pj, "type");
        p.name = getString(pj, "name");
        p.config = getString(pj, "config");
        p.order_ = jsonInt(pj, "order");
        r.processors ~= p;
      }

      auto result = usecase.createPipeline(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Pipeline created");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto pipelines = usecase.listPipelines(tenantId);

      auto jarr = Json.emptyArray;
      foreach (p; pipelines) {
        jarr ~= Json.emptyObject
          .set("id", p.id)
          .set("name", p.name)
          .set("description", p.description)
          .set("isActive", p.isActive);
      }

      auto resp = Json.emptyObject
        .set("items", jarr)
        .set("totalCount", pipelines.length)
        .set("message", "Pipeline list retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = PipelineId(extractIdFromPath(req.requestURI.to!string));
      auto p = usecase.getPipeline(tenantId, id);
      if (p.isNull) {
        writeError(res, 404, "Pipeline not found");
        return;
      }

      auto response = Json.emptyObject
        .set("id", p.id)
        .set("name", p.name)
        .set("description", p.description)
        .set("isActive", p.isActive)
        .set("targetStreamId", p.targetStreamId)
        .set("message", "Pipeline retrieved successfully");

      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = PipelineId(extractIdFromPath(req.requestURI.to!string));
      auto j = req.json;

      UpdatePipelineRequest r;
      r.pipelineId = id;
      r.description = j.getString("description");
      r.format = j.getString("format");
      r.targetStreamId = j.getString("targetStreamId");
      r.isActive = j.getBoolean("isActive", true);
      r.tenantId = tenantId;

      auto result = usecase.updatePipeline(r);
      if (result.success) {
        auto response = Json.emptyObject
          .set("id", result.id)
          .set("message", "Pipeline updated");

        res.writeJsonBody(response, 200);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto pipelineId = PipelineId(extractIdFromPath(req.requestURI.to!string));
      
      usecase.deletePipeline(tenantId, pipelineId);
      auto response = Json.emptyObject
        .set("id", pipelineId)
        .set("message", "Pipeline deleted");

      res.writeJsonBody(response, 204);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
