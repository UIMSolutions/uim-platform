/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_attribute_recommendation.presentation.http.controllers.model;


// 
// import uim.platform.data_attribute_recommendation.application.usecases.manage.models;
// import uim.platform.data_attribute_recommendation.application.dto;
// import uim.platform.data_attribute_recommendation.domain.entities.model_configuration;
// import uim.platform.data_attribute_recommendation.domain.types;
import uim.platform.data_attribute_recommendation;

mixin(ShowModule!());
@safe:
class ModelController : ManageController {
  private ManageModelsUseCase usecase;

  this(ManageModelsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/models", &handleCreate);
    router.get("/api/v1/models", &handleList);
    router.get("/api/v1/models/*", &handleGet);
    router.put("/api/v1/models/*", &handleUpdate);
    router.delete_("/api/v1/models/*", &handleDelete);
    router.post("/api/v1/models/activate/*", &handleActivate);
    router.post("/api/v1/models/train/*", &handleTrain);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
      auto r = CreateModelConfigRequest();
      r.tenantId = tenantId;
      r.datasetId = data.getString("datasetId");
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.modelType = parseModelType(data.getString("modelType"));
      r.targetColumns = data.getString("targetColumns");
      r.featureColumns = data.getString("featureColumns");
      r.hyperparameters = data.getString("hyperparameters");
      r.createdBy = UserId(req.headers.get("X-User-Id", "system"));

      auto result = usecase.createModelConfig(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Model configuration created successfully");

        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.message);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

      auto items = usecase.listModelConfigs(tenantId);
      auto arr = items.map!(c => c.toJson).array.toJson;

      auto resp = Json.emptyObject
            .set("items", arr)
            .set("totalCount", items.length)
            .set("message", "Model configurations retrieved successfully");

      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto config = usecase.getModelConfig(tenantId, id);
      if (config.isNull) {
        writeError(res, 404, "Model configuration not found");
        return;
      }
      res.writeJsonBody(config.toJson, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto data = precheck.data;
      auto r = UpdateModelConfigRequest();
      r.id = id;
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.modelType = parseModelType(data.getString("modelType"));
      r.targetColumns = data.getString("targetColumns");
      r.featureColumns = data.getString("featureColumns");
      r.hyperparameters = data.getString("hyperparameters");

      auto result = usecase.updateModelConfig(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Model configuration updated successfully");

        res.writeJsonBody(resp, 200);
      }
      else
      {
        auto status = result.message == "Model configuration not found" ? 404 : 400;
        writeError(res, status, result.message);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto result = usecase.activateConfig(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("status", Json("ready"))
            .set("message", "Model configuration activated successfully");

        res.writeJsonBody(resp, 200);
      }
      else
      {
        auto status = result.message == "Model configuration not found" ? 404 : 400;
        writeError(res, status, result.message);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleTrain(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto r = StartTrainingRequest();
      r.modelConfigId = id;
      r.tenantId = tenantId;
      r.createdBy = UserId(req.headers.get("X-User-Id", "system"));

      auto result = usecase.startTraining(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
            .set("jobId", result.id)
            .set("status", Json("running"))
            .set("message", "Model training started successfully");

        res.writeJsonBody(resp, 202);
      }
      else
        writeError(res, 400, result.message);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto result = usecase.deleteModelConfig(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
            .set("deleted", true)
            .set("message", "Model configuration deleted successfully");
            
        res.writeJsonBody(resp, 200);
      }
      else
      {
        auto status = result.message == "Model configuration not found" ? 404 : 400;
        writeError(res, status, result.message);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeConfig(const ModelConfiguration c) {
    return Json.emptyObject
    .set("id", c.id)
    .set("tenantId", c.tenantId)
    .set("datasetId", c.datasetId)
    .set("name", c.name)
    .set("description", c.description)
    .set("modelType", c.modelType.to!string)
    .set("targetColumns", c.targetColumns)
    .set("featureColumns", c.featureColumns)
    .set("hyperparameters", c.hyperparameters)
    .set("status", c.status.to!string)
    .set("createdBy", c.createdBy)
    .set("createdAt", c.createdAt)
    .set("updatedAt", c.updatedAt);
  }
}
