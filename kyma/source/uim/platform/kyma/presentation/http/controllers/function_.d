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

// import uim.platform.kyma.application.usecases.manage.functions;
// import uim.platform.kyma.application.dto;
// import uim.platform.kyma.domain.entities.serverless_function;
// import uim.platform.kyma.domain.types;
// import uim.platform.kyma.presentation.http.json_utils;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
class FunctionController : PlatformController {
  private ManageFunctionsUseCase uc;

  this(ManageFunctionsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/functions", &handleCreate);
    router.get("/api/v1/functions", &handleList);
    router.get("/api/v1/functions/*", &handleGetById);
    router.put("/api/v1/functions/*", &handleUpdate);
    router.delete_("/api/v1/functions/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateFunctionRequest r;
      r.namespaceId = j.getString("namespaceId");
      r.environmentId = j.getString("environmentId");
      r.tenantId = req.getTenantId;
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
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto nsId = req.params.get("namespaceId");
      auto envId = req.params.get("environmentId");

      ServerlessFunction[] items;
      if (nsId.length > 0)
        items = uc.listByNamespace(NamespaceId(nsId));
      else if (envId.length > 0)
        items = uc.listByEnvironment(envId);
      else
        items = [];

      auto arr = Json.emptyArray;
      foreach (fn; items)
        arr ~= serializeFn(fn);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(items.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      if (!uc.hasFunction(ServerlessFunctionId(id))) {
        writeError(res, 404, "Function not found");
        return;
      }
      auto fn = uc.getFunction(ServerlessFunctionId(id));
      res.writeJsonBody(serializeFn(fn), 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
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

      auto result = uc.updateFunction(ServerlessFunctionId(id), r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.deleteFunction(ServerlessFunctionId(id));
      if (result.success)
        res.writeBody("", 204);
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private Json serializeFn(ServerlessFunction fn) {
    return Json.emptyObject
     .set("id", fn.id)
     .set("namespaceId", fn.namespaceId)
     .set("environmentId", fn.environmentId)
     .set("tenantId", fn.tenantId)
     .set("name", fn.name)
     .set("description", fn.description)
     .set("runtime", fn.runtime.to!string)
     .set("status", fn.status.to!string)
     .set("handler", fn.handler)
     .set("scalingType", fn.scalingType.to!string)
     .set("minReplicas", fn.minReplicas)
     .set("maxReplicas", fn.maxReplicas)
     .set("cpuRequest", fn.cpuRequest)
     .set("cpuLimit", fn.cpuLimit)
     .set("memoryRequest", fn.memoryRequest)
     .set("memoryLimit", fn.memoryLimit)
     .set("envVars", serializeStrMap(fn.envVars))
     .set("labels", serializeStrMap(fn.labels))
     .set("timeoutSeconds", fn.timeoutSeconds)
     .set("createdBy", fn.createdBy)
     .set("createdAt", fn.createdAt)
     .set("modifiedAt", fn.modifiedAt);
  }
}
