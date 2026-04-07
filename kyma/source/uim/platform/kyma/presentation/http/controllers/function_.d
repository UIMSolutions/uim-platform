/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.presentation.http.controllers.function_;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

import uim.platform.kyma.application.usecases.manage.functions;
import uim.platform.kyma.application.dto;
import uim.platform.kyma.domain.entities.serverless_function;
import uim.platform.kyma.domain.types;
import uim.platform.kyma.presentation.http.json_utils;

class FunctionController {
  private ManageFunctionsUseCase uc;

  this(ManageFunctionsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    router.post("/api/v1/functions", &handleCreate);
    router.get("/api/v1/functions", &handleList);
    router.get("/api/v1/functions/*", &handleGetById);
    router.put("/api/v1/functions/*", &handleUpdate);
    router.delete_("/api/v1/functions/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try
    {
      auto j = req.json;
      CreateFunctionRequest r;
      r.namespaceId = j.getString("namespaceId");
      r.environmentId = j.getString("environmentId");
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.runtime = j.getString("runtime");
      r.sourceCode = j.getString("sourceCode");
      r.handler = j.getString("handler");
      r.dependencies = j.getString("dependencies");
      r.scalingType = j.getString("scalingType");
      r.minReplicas = j.getInteger("minReplicas");
      r.maxReplicas = j.getInteger("maxReplicas");
      r.cpuRequest = j.getString("cpuRequest");
      r.cpuLimit = j.getString("cpuLimit");
      r.memoryRequest = j.getString("memoryRequest");
      r.memoryLimit = j.getString("memoryLimit");
      r.envVars = jsonStrMap(j, "envVars");
      r.labels = jsonStrMap(j, "labels");
      r.timeoutSeconds = j.getInteger("timeoutSeconds");
      r.createdBy = req.headers.get("X-User-Id", "");

      auto result = uc.create(r);
      if (result.success)
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

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try
    {
      auto nsId = req.params.get("namespaceId");
      auto envId = req.params.get("environmentId");

      ServerlessFunction[] items;
      if (nsId.length > 0)
        items = uc.listByNamespace(nsId);
      else if (envId.length > 0)
        items = uc.listByEnvironment(envId);
      else
        items = [];

      auto arr = Json.emptyArray;
      foreach (ref fn; items)
        arr ~= serializeFn(fn);

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

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto fn = uc.getFunction(id);
      if (fn.id.length == 0)
      {
        writeError(res, 404, "Function not found");
        return;
      }
      res.writeJsonBody(serializeFn(fn), 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      UpdateFunctionRequest r;
      r.description = j.getString("description");
      r.sourceCode = j.getString("sourceCode");
      r.handler = j.getString("handler");
      r.dependencies = j.getString("dependencies");
      r.scalingType = j.getString("scalingType");
      r.minReplicas = j.getInteger("minReplicas");
      r.maxReplicas = j.getInteger("maxReplicas");
      r.cpuRequest = j.getString("cpuRequest");
      r.cpuLimit = j.getString("cpuLimit");
      r.memoryRequest = j.getString("memoryRequest");
      r.memoryLimit = j.getString("memoryLimit");
      r.envVars = jsonStrMap(j, "envVars");
      r.labels = jsonStrMap(j, "labels");
      r.timeoutSeconds = j.getInteger("timeoutSeconds");

      auto result = uc.updateFunction(id, r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.deleteFunction(id);
      if (result.success)
        res.writeBody("", 204);
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private Json serializeFn(ref ServerlessFunction fn) {
    auto j = Json.emptyObject;
    j["id"] = Json(fn.id);
    j["namespaceId"] = Json(fn.namespaceId);
    j["environmentId"] = Json(fn.environmentId);
    j["tenantId"] = Json(fn.tenantId);
    j["name"] = Json(fn.name);
    j["description"] = Json(fn.description);
    j["runtime"] = Json(fn.runtime.to!string);
    j["status"] = Json(fn.status.to!string);
    j["handler"] = Json(fn.handler);
    j["scalingType"] = Json(fn.scalingType.to!string);
    j["minReplicas"] = Json(cast(long) fn.minReplicas);
    j["maxReplicas"] = Json(cast(long) fn.maxReplicas);
    j["cpuRequest"] = Json(fn.cpuRequest);
    j["cpuLimit"] = Json(fn.cpuLimit);
    j["memoryRequest"] = Json(fn.memoryRequest);
    j["memoryLimit"] = Json(fn.memoryLimit);
    j["envVars"] = serializeStrMap(fn.envVars);
    j["labels"] = serializeStrMap(fn.labels);
    j["timeoutSeconds"] = Json(cast(long) fn.timeoutSeconds);
    j["createdBy"] = Json(fn.createdBy);
    j["createdAt"] = Json(fn.createdAt);
    j["modifiedAt"] = Json(fn.modifiedAt);
    return j;
  }
}
