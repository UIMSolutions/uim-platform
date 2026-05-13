/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.presentation.http.controllers.execution;

// import uim.platform.ai_core.application.usecases.manage.executions;
// import uim.platform.ai_core.application.dto;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

class ExecutionController : PlatformController {
  private ManageExecutionsUseCase usecase;

  this(ManageExecutionsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v2/lm/executions", &handleCreate);
    router.get("/api/v2/lm/executions", &handleList);
    router.get("/api/v2/lm/executions/*", &handleGet);
    router.patch_("/api/v2/lm/executions/*", &handlePatch);
    router.delete_("/api/v2/lm/executions/*", &handleDelete);
  }

  protected void handleGetCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateExecutionRequest r;
      r.tenantId = tenantId;
      r.resourceGroupId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));
      r.configurationId = j.getString("configurationId");

      auto result = usecase.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Execution scheduled")
          .set("status", "PENDING");

        res.writeJsonBody(resp, 202);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));
      auto executions = usecase.list(rgId);

      auto jarr = executions.map!(ex => executionToJson(ex)).array.toJson;

      auto resp = Json.emptyObject
        .set("count", executions.length)
        .set("resources", jarr)
        .set("message", "Executions retrieved");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = ExecutionId(extractIdFromPath(req.requestURI.to!string));
      auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));

      auto ex = usecase.getExecution(tenantId, rgId, id);
      if (ex.isNull) {
        writeError(res, 404, "Execution not found");
        return;
      }

      res.writeJsonBody(executionToJson(ex), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetPatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = ExecutionId(extractIdFromPath(req.requestURI.to!string));
      auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));

      auto j = req.json;
      PatchExecutionRequest r;
      r.tenantId = tenantId;
      r.resourceGroupId = rgId;
      r.executionId = id;
      r.targetStatus = j.getString("targetStatus");

      auto result = usecase.patch(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Execution modified");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = ExecutionId(extractIdFromPath(req.requestURI.to!string));
      auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));

      auto result = usecase.deleteExecution(tenantId, rgId, id);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
