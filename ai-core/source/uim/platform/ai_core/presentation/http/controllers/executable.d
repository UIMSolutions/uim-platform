/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.presentation.http.controllers.executable;
// import uim.platform.ai_core.application.usecases.manage.executables;
// import uim.platform.ai_core.application.dto;
// import uim.platform.ai_core;
import uim.platform.ai_core;

mixin(ShowModule!());

@safe:
class ExecutableController : ManageController {
  private ManageExecutablesUseCase usecase;

  this(ManageExecutablesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v2/lm/executables", &handleList);
    router.get("/api/v2/lm/executables/*", &handleGet);
    router.post("/api/v2/lm/executables", &handleCreate);
    router.delete_("/api/v2/lm/executables/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;

      CreateExecutableRequest r;
      r.tenantId = tenantId;
      r.resourceGroupId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));
      r.scenarioId = ScenarioId(j.getString("scenarioId"));
      r.executableId = ExecutableId(j.getString("id"));
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.type = j.getString("type");
      r.versionId = j.getString("versionId");
      r.deployable = j.getString("deployable");

      auto result = usecase.createExecutable(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Executable registered");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));
      auto scenarioId = ScenarioId(req.params.get("scenarioId", ""));

      auto executables = scenarioId.isEmpty
        ? usecase.listExecutables(tenantId, rgId) : usecase.listExecutables(tenantId, rgId, scenarioId);

      auto jarr = Json.emptyArray;
      foreach (e; executables) {
        jarr ~= Json.emptyObject
          .set("id", e.id)
          .set("scenarioId", e.scenarioId)
          .set("name", e.name)
          .set("description", e.description)
          .set("type", e.type == ExecutableType.serving ? "serving" : "workflow")
          .set("versionId", e.versionId)
          .set("deployable", e.deployable)
          .set("createdAt", e.createdAt)
          .set("updatedAt", e.updatedAt);
      }

      auto resp = Json.emptyObject
        .set("resources", jarr)
        .set("totalCount", executables.length)
        .set("message", "Executables retrieved");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = Executableprecheck.id);
      auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));

      auto e = usecase.getExecutable(tenantId, rgId, id);
      if (e.isNull) {
        writeError(res, 404, "Executable not found");
        return;
      }

      auto resp = Json.emptyObject
        .set("id", e.id)
        .set("scenarioId", e.scenarioId)
        .set("name", e.name)
        .set("description", e.description)
        .set("type", e.type == ExecutableType.serving ? "serving" : "workflow")
        .set("versionId", e.versionId)
        .set("deployable", e.deployable)
        .set("createdAt", e.createdAt)
        .set("updatedAt", e.updatedAt)
        .set("message", "Executable retrieved");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = Executableprecheck.id);
      auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));

      auto result = usecase.deleteExecutable(tenantId, rgId, id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto response = Json.emptyObject
          .set("id", id)
          .set("message", "Executable deleted");

        res.writeJsonBody(response, 204);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
