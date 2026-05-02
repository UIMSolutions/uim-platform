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

class PipelineController : PlatformController {
  private ManagePipelinesUseCase uc;

  this(ManagePipelinesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/pipelines", &handleCreate);
    router.get("/api/v1/pipelines", &handleList);
    router.get("/api/v1/pipelines/*", &handleGet);
    router.put("/api/v1/pipelines/*", &handleUpdate);
    router.delete_("/api/v1/pipelines/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreatePipelineRequest r;
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.sourceType = j.getString("sourceType");
      r.format = j.getString("format");
      r.targetStreamId = j.getString("targetStreamId");
      r.createdBy = j.getString("createdBy");

      auto processorsVal = "processors" in j;
      if (processorsVal !is null && (processorsVal).isArray) {
        foreach (pj; *processorsVal) {
          ProcessorDTO p;
          p.type = getString(pj, "type");
          p.name = getString(pj, "name");
          p.config = getString(pj, "config");
          p.order_ = jsonInt(pj, "order");
          r.processors ~= p;
        }
      }

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
        .set("id", result.id);

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto pipelines = uc.list(tenantId);

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
        .set("totalCount", pipelines.length);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto p = uc.getById(id);
      if (p.isNull) {
        writeError(res, 404, "Pipeline not found");
        return;
      }

      auto response = Json.emptyObject
        .set("id", p.id)
        .set("name", p.name)
        .set("description", p.description)
        .set("isActive", p.isActive)
        .set("targetStreamId", p.targetStreamId);

      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto j = req.json;
      UpdatePipelineRequest r;
      r.description = j.getString("description");
      r.format = j.getString("format");
      r.targetStreamId = j.getString("targetStreamId");
      r.isActive = j.getBoolean("isActive", true);

      auto result = uc.update(id, r);
      if (result.success) {
        auto response = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(response, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      uc.removeById(id);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
