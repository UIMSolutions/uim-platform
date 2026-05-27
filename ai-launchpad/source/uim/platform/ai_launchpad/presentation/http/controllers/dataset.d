/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.presentation.http.controllers.dataset;

// import uim.platform.ai_launchpad.application.usecases.manage.datasets;
// import uim.platform.ai_launchpad.application.dto;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

class DatasetController : ManageController {
  private ManageDatasetsUseCase usecase;

  this(ManageDatasetsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/datasets", &handleRegister);
    router.get("/api/v1/datasets", &handleList);
    router.get("/api/v1/datasets/*", &handleGet);
    router.patch("/api/v1/datasets/*", &handlePatch);
    router.delete_("/api/v1/datasets/*", &handleDelete);
  }

  protected void handleRegister(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto j = req.json;
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

      RegisterDatasetRequest r;
      r.tenantId = tenantId;
      r.connectionId = connectionId;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.scenarioId = data.getString("scenarioId");
      r.url = data.getString("url");
      r.size = jsonLong(j, "size");
      r.labels = getStrings(j, "labels");

      auto result = usecase.registerDataset(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Dataset registered");

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
      auto tenantId = precheck.tenantId;
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));
      auto scenarioId = ScenarioId(req.headers.get("X-Scenario-Id", ""));

      auto datasets = scenarioId.isEmpty
        ? usecase.listDatasets(tenantId, connectionId)
        : usecase.listDatasets(tenantId, connectionId, scenarioId);

      auto jarr = datasets.map!(ds => ds.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("count", Json(datasets.length))
        .set("resources", jarr)
        .set("message", "Datasets retrieved");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = Datasetprecheck.id);
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

      auto d = usecase.getDataset(tenantId, connectionId, id);
      if (d.isNull) {
        writeError(res, 404, "Dataset not found");
        return;
      }

      auto resp = d.toJson
        .set("message", "Dataset retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handlePatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = Datasetprecheck.id);
      auto j = req.json;
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

      PatchDatasetRequest r;
      r.tenantId = tenantId;
      r.connectionId = connectionId;
      r.datasetId = id;
      r.description = data.getString("description");
      r.status = data.getString("status");

      auto result = usecase.patchDataset(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("message", "Dataset updated successfully");
          
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));
      auto id = Datasetprecheck.id);

      auto result = usecase.deleteDataset(tenantId, connectionId, id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("message", "Dataset deleted successfully");

        res.writeJsonBody(resp, 204);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

}
