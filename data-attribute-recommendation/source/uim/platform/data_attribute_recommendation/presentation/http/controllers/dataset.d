/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_attribute_recommendation.presentation.http.controllers.dataset;

// 
// 
// import uim.platform.data_attribute_recommendation.application.usecases.manage.datasets;
// import uim.platform.data_attribute_recommendation.application.dto;
// import uim.platform.data_attribute_recommendation.domain.entities.dataset;
// import uim.platform.data_attribute_recommendation.domain.types;
import uim.platform.data_attribute_recommendation;

mixin(ShowModule!());
@safe:
class DatasetController : ManageController {
  private ManageDatasetsUseCase usecase;

  this(ManageDatasetsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/datasets", &handleCreate);
    router.get("/api/v1/datasets", &handleList);
    router.get("/api/v1/datasets/*", &handleGet);
    router.put("/api/v1/datasets/*", &handleUpdate);
    router.delete_("/api/v1/datasets/*", &handleDelete);
    router.post("/api/v1/datasets/validate/*", &handleValidate);
    router.post("/api/v1/datasets/process/*", &handleProcess);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto j = req.json;
      auto r = CreateDatasetRequest();
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.dataType = parseDataType(j.getString("dataType"));
      r.columnDefinitions = j.getString("columnDefinitions");
      r.createdBy = UserId(req.headers.get("X-User-Id", "system"));

      auto result = usecase.createDataset(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Dataset created successfully");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;

      auto items = usecase.listDatasets(tenantId);
      auto arr = items.map!(d => d.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length)
        .set("message", "Datasets retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;

      auto ds = usecase.getDataset(tenantId, id);
      if (ds.isNull) {
        writeError(res, 404, "Dataset not found");
        return;
      }
      res.writeJsonBody(ds.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto j = req.json;

      auto r = UpdateDatasetRequest();
      r.tenantId = tenantId;
      r.datasetId = id;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.columnDefinitions = j.getString("columnDefinitions");

      auto result = usecase.updateDataset(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Dataset updated successfully");

        res.writeJsonBody(resp, 200);
      } else {
        auto status = result.message == "Dataset not found" ? 404 : 400;
        writeError(res, status, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleValidate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;

      auto result = usecase.validateDataset(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", Json("ready"))
          .set("message", "Dataset validated successfully");

        res.writeJsonBody(resp, 200);
      } else {
        auto status = result.message == "Dataset not found" ? 404 : 400;
        writeError(res, status, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleProcess(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;

      auto result = usecase.processDataset(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", Json("completed"))
          .set("message", "Dataset processed successfully");

        res.writeJsonBody(resp, 200);
      } else {
        auto status = result.message == "Dataset not found" ? 404 : 400;
        writeError(res, status, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;

      auto result = usecase.deleteDataset(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("deleted", true)
          .set("message", "Dataset deleted successfully");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 404, result.message);
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
