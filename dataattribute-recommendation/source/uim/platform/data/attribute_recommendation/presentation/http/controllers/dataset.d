/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.presentation.http.controllers.dataset_controller;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// // import std.conv : to;
// 
// import uim.platform.data.attribute_recommendation.application.usecases.manage.datasets;
// import uim.platform.data.attribute_recommendation.application.dto;
// import uim.platform.data.attribute_recommendation.domain.entities.dataset;
// import uim.platform.data.attribute_recommendation.domain.types;
import uim.platform.data.attribute_recommendation;

mixin(ShowModule!());
@safe:
class DatasetController : PlatformController {
  private ManageDatasetsUseCase uc;

  this(ManageDatasetsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/datasets", &handleCreate);
    router.get("/api/v1/datasets", &handleList);
    router.get("/api/v1/datasets/*", &handleGetById);
    router.put("/api/v1/datasets/*", &handleUpdate);
    router.delete_("/api/v1/datasets/*", &handleDelete);
    router.post("/api/v1/datasets/validate/*", &handleValidate);
    router.post("/api/v1/datasets/process/*", &handleProcess);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateDatasetRequest();
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.dataType = parseDataType(j.getString("dataType"));
      r.columnDefinitions = j.getString("columnDefinitions");
      r.createdBy = req.headers.get("X-User-Id", "system");

      auto result = uc.createDataset(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
            .set("id", Json(result.id))
            .set("message", "Dataset created successfully");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto items = uc.listDatasets(tenantId);

      auto arr = Json.emptyArray;
      foreach (d; items)
        arr ~= serializeDataset(d);

      auto resp = Json.emptyObject
            .set("items", arr)
            .set("totalCount", Json(items.length))
            .set("message", "Datasets retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto ds = uc.getDataset(tenantId, id);
      if (ds is null) {
        writeError(res, 404, "Dataset not found");
        return;
      }
      res.writeJsonBody(serializeDataset(*ds), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdateDatasetRequest();
      r.id = id;
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.columnDefinitions = j.getString("columnDefinitions");

      auto result = uc.updateDataset(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
            .set("id", Json(result.id))
            .set("message", "Dataset updated successfully");

        res.writeJsonBody(resp, 200);
      } else {
        auto status = result.error == "Dataset not found" ? 404 : 400;
        writeError(res, status, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleValidate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = uc.validateDataset(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
            .set("id", Json(result.id))
            .set("status", Json("ready"))
            .set("message", "Dataset validated successfully");

        res.writeJsonBody(resp, 200);
      } else {
        auto status = result.error == "Dataset not found" ? 404 : 400;
        writeError(res, status, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleProcess(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = uc.processDataset(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
            .set("id", Json(result.id))
            .set("status", Json("completed"))
            .set("message", "Dataset processed successfully");

        res.writeJsonBody(resp, 200);
      } else {
        auto status = result.error == "Dataset not found" ? 404 : 400;
        writeError(res, status, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = uc.deleteDataset(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("deleted", true)
            .set("message", "Dataset deleted successfully");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeDataset(const Dataset d) {
    return Json.emptyObject
      .set("id", d.id)
      .set("tenantId", d.tenantId)
      .set("name", d.name)
      .set("description", d.description)
      .set("status", d.status.to!string)
      .set("dataType", d.dataType.to!string)
      .set("columnDefinitions", d.columnDefinitions)
      .set("rowCount", d.rowCount)
      .set("validationMessage", d.validationMessage)
      .set("createdBy", d.createdBy)
      .set("createdAt", d.createdAt)
      .set("updatedAt", d.updatedAt);
  }
}
