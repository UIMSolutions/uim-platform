module presentation.http.model;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import application.usecases.manage_models;
import application.dto;
import domain.entities.model_configuration;
import domain.types;
import presentation.http.json_utils;

class ModelController
{
  private ManageModelsUseCase uc;

  this(ManageModelsUseCase uc)
  {
    this.uc = uc;
  }

  void registerRoutes(URLRouter router)
  {
    router.post("/api/v1/models", &handleCreate);
    router.get("/api/v1/models", &handleList);
    router.get("/api/v1/models/*", &handleGetById);
    router.put("/api/v1/models/*", &handleUpdate);
    router.delete_("/api/v1/models/*", &handleDelete);
    router.post("/api/v1/models/activate/*", &handleActivate);
    router.post("/api/v1/models/train/*", &handleTrain);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto j = req.json;
      auto r = CreateModelConfigRequest();
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.datasetId = jsonStr(j, "datasetId");
      r.name = jsonStr(j, "name");
      r.description = jsonStr(j, "description");
      r.modelType = parseModelType(jsonStr(j, "modelType"));
      r.targetColumns = jsonStr(j, "targetColumns");
      r.featureColumns = jsonStr(j, "featureColumns");
      r.hyperparameters = jsonStr(j, "hyperparameters");
      r.createdBy = req.headers.get("X-User-Id", "system");

      auto result = uc.createModelConfig(r);
      if (result.isSuccess)
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto items = uc.listModelConfigs(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref c; items)
        arr ~= serializeConfig(c);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) items.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto config = uc.getModelConfig(id, tenantId);
      if (config is null)
      {
        writeError(res, 404, "Model configuration not found");
        return;
      }
      res.writeJsonBody(serializeConfig(*config), 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdateModelConfigRequest();
      r.id = id;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.name = jsonStr(j, "name");
      r.description = jsonStr(j, "description");
      r.modelType = parseModelType(jsonStr(j, "modelType"));
      r.targetColumns = jsonStr(j, "targetColumns");
      r.featureColumns = jsonStr(j, "featureColumns");
      r.hyperparameters = jsonStr(j, "hyperparameters");

      auto result = uc.updateModelConfig(r);
      if (result.isSuccess)
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      }
      else
      {
        auto status = result.error == "Model configuration not found" ? 404 : 400;
        writeError(res, status, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto result = uc.activateConfig(id, tenantId);
      if (result.isSuccess)
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["status"] = Json("ready");
        res.writeJsonBody(resp, 200);
      }
      else
      {
        auto status = result.error == "Model configuration not found" ? 404 : 400;
        writeError(res, status, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleTrain(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto r = StartTrainingRequest();
      r.modelConfigId = id;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.createdBy = req.headers.get("X-User-Id", "system");

      auto result = uc.startTraining(r);
      if (result.isSuccess)
      {
        auto resp = Json.emptyObject;
        resp["jobId"] = Json(result.id);
        resp["status"] = Json("running");
        res.writeJsonBody(resp, 202);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto result = uc.deleteModelConfig(id, tenantId);
      if (result.isSuccess)
      {
        auto resp = Json.emptyObject;
        resp["deleted"] = Json(true);
        res.writeJsonBody(resp, 200);
      }
      else
      {
        auto status = result.error == "Model configuration not found" ? 404 : 400;
        writeError(res, status, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeConfig(ref const ModelConfiguration c)
  {
    auto j = Json.emptyObject;
    j["id"] = Json(c.id);
    j["tenantId"] = Json(c.tenantId);
    j["datasetId"] = Json(c.datasetId);
    j["name"] = Json(c.name);
    j["description"] = Json(c.description);
    j["modelType"] = Json(c.modelType.to!string);
    j["targetColumns"] = Json(c.targetColumns);
    j["featureColumns"] = Json(c.featureColumns);
    j["hyperparameters"] = Json(c.hyperparameters);
    j["status"] = Json(c.status.to!string);
    j["createdBy"] = Json(c.createdBy);
    j["createdAt"] = Json(c.createdAt);
    j["updatedAt"] = Json(c.updatedAt);
    return j;
  }
}
