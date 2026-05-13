/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.presentation.http.controllers.model;

// import uim.platform.ai_launchpad.application.usecases.manage.models;
// import uim.platform.ai_launchpad.application.dto;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:
class ModelController : PlatformController {
  private ManageModelsUseCase usecase;

  this(ManageModelsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/models", &handleRegister);
    router.get("/api/v1/models", &handleList);
    router.get("/api/v1/models/*", &handleGet);
    router.patch("/api/v1/models/*", &handlePatch);
    router.delete_("/api/v1/models/*", &handleDelete);
  }

  protected void handleGetRegister(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

      RegisterModelRequest r;
      r.connectionId = connectionId;
      r.name = j.getString("name");
      r.version_ = j.getString("version");
      r.description = j.getString("description");
      r.scenarioId = j.getString("scenarioId");
      r.executionId = j.getString("executionId");
      r.url = j.getString("url");
      r.size = jsonLong(j, "size");
      r.labels = getStrings(j, "labels");

      auto result = usecase.register(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Model registered");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));
      auto scenarioId = ScenarioId(req.headers.get("X-Scenario-Id", ""));

      auto models = scenarioId.isEmpty
        ? usecase.listByConnection(tenantId, connectionId)
        : usecase.listByScenario(tenantId, connectionId, scenarioId);

      auto jarr = models.map!(m => m.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("count", models.length)
        .set("resources", jarr);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = ModelId(extractIdFromPath(req.requestURI.to!string));
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

      auto model = usecase.getModel(tenantId, connectionId, id);
      if (model.isNull) {
        writeError(res, 404, "Model not found");
        return;
      }

      res.writeJsonBody(model.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetPatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = ModelId(extractIdFromPath(req.requestURI.to!string));
      auto j = req.json;
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

      PatchModelRequest r;
      r.tenantId = tenantId;
      r.connectionId = connectionId;
      r.modelId = id;
      r.description = j.getString("description");
      r.status = j.getString("status");

      auto result = usecase.patchModel(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Model updated");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));
      auto id = ModelId(extractIdFromPath(req.requestURI.to!string));

      auto result = usecase.deleteModel(tenantId, connectionId, id);
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
