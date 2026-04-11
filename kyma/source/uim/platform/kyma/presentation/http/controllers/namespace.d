/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.presentation.http.controllers.namespace;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

// import uim.platform.kyma.application.usecases.manage.namespaces;
// import uim.platform.kyma.application.dto;
// import uim.platform.kyma.domain.entities.namespace;
// import uim.platform.kyma.domain.types;
// import uim.platform.kyma.presentation.http.json_utils;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
class NamespaceController : PlatformController {
  private ManageNamespacesUseCase uc;

  this(ManageNamespacesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/namespaces", &handleCreate);
    router.get("/api/v1/namespaces", &handleList);
    router.get("/api/v1/namespaces/*", &handleGetById);
    router.put("/api/v1/namespaces/*", &handleUpdate);
    router.delete_("/api/v1/namespaces/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateNamespaceRequest r;
      r.environmentId = j.getString("environmentId");
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.cpuLimit = j.getString("cpuLimit");
      r.memoryLimit = j.getString("memoryLimit");
      r.cpuRequest = j.getString("cpuRequest");
      r.memoryRequest = j.getString("memoryRequest");
      r.podLimit = j.getInteger("podLimit");
      r.quotaEnforcement = j.getString("quotaEnforcement");
      r.istioInjection = j.getBoolean("istioInjection", true);
      r.labels = jsonStrMap(j, "labels");
      r.annotations = jsonStrMap(j, "annotations");
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
      auto envIdParam = req.params.get("environmentId");
      string envId = envIdParam.length > 0 ? envIdParam : req.headers.get("X-Environment-Id", "");

      auto items = uc.listByEnvironment(envId);
      auto arr = Json.emptyArray;
      foreach (ns; items)
        arr ~= serializeNs(ns);

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
      auto ns = uc.getNamespace(id);
      if (ns.id.isEmpty) {
        writeError(res, 404, "Namespace not found");
        return;
      }
      res.writeJsonBody(serializeNs(ns), 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      UpdateNamespaceRequest r;
      r.description = j.getString("description");
      r.cpuLimit = j.getString("cpuLimit");
      r.memoryLimit = j.getString("memoryLimit");
      r.cpuRequest = j.getString("cpuRequest");
      r.memoryRequest = j.getString("memoryRequest");
      r.podLimit = j.getInteger("podLimit");
      r.quotaEnforcement = j.getString("quotaEnforcement");
      r.istioInjection = j.getBoolean("istioInjection", true);
      r.labels = jsonStrMap(j, "labels");
      r.annotations = jsonStrMap(j, "annotations");

      auto result = uc.updateNamespace(id, r);
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
      auto result = uc.deleteNamespace(id);
      if (result.success)
        res.writeBody("", 204);
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private Json serializeNs(Namespace ns) {
    auto j = Json.emptyObject;
    j["id"] = Json(ns.id);
    j["environmentId"] = Json(ns.environmentId);
    j["tenantId"] = Json(ns.tenantId);
    j["name"] = Json(ns.name);
    j["description"] = Json(ns.description);
    j["status"] = Json(ns.status.to!string);
    j["cpuLimit"] = Json(ns.cpuLimit);
    j["memoryLimit"] = Json(ns.memoryLimit);
    j["cpuRequest"] = Json(ns.cpuRequest);
    j["memoryRequest"] = Json(ns.memoryRequest);
    j["podLimit"] = Json(ns.podLimit);
    j["quotaEnforcement"] = Json(ns.quotaEnforcement.to!string);
    j["istioInjection"] = Json(ns.istioInjection);
    j["labels"] = serializeStrMap(ns.labels);
    j["annotations"] = serializeStrMap(ns.annotations);
    j["createdBy"] = Json(ns.createdBy);
    j["createdAt"] = Json(ns.createdAt);
    j["modifiedAt"] = Json(ns.modifiedAt);
    return j;
  }
}
