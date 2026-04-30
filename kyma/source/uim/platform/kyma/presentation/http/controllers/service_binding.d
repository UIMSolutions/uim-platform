/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.presentation.http.controllers.service_binding;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

// import uim.platform.kyma.application.usecases.manage.service_bindings;
// import uim.platform.kyma.application.dto;
// import uim.platform.kyma.domain.entities.service_binding;
// import uim.platform.kyma.domain.types;
// import uim.platform.kyma.presentation.http.json_utils;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
class ServiceBindingController : PlatformController {
  private ManageServiceBindingsUseCase uc;

  this(ManageServiceBindingsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/service-bindings", &handleCreate);
    router.get("/api/v1/service-bindings", &handleList);
    router.get("/api/v1/service-bindings/*", &handleGetById);
    router.put("/api/v1/service-bindings/*", &handleUpdate);
    router.delete_("/api/v1/service-bindings/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateServiceBindingRequest r;
      r.serviceInstanceId = j.getString("serviceInstanceId");
      r.namespaceId = j.getString("namespaceId");
      r.environmentId = j.getString("environmentId");
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.secretName = j.getString("secretName");
      r.secretNamespace = j.getString("secretNamespace");
      r.parametersJson = j.getString("parameters");
      r.labels = jsonStrMap(j, "labels");
      r.createdBy = req.headers.get("X-User-Id", "");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id);

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
      auto instId = req.params.get("serviceInstanceId");

      ServiceBinding[] items;
      if (instId.length > 0)
        items = uc.listByServiceInstance(ServiceInstanceId(instId));
      else if (nsId.length > 0)
        items = uc.listByNamespace(NamespaceId(nsId));
      else
        items = [];

      auto arr = Json.emptyArray;
      foreach (b; items)
        arr ~= serializeBinding(b);

      auto resp = Json.emptyObject
          .set("items", arr)
          .set("totalCount", items.length);
          
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto b = uc.getBinding(ServiceBindingId(id));
      if (b.id.isEmpty) {
        writeError(res, 404, "Service binding not found");
        return;
      }
      res.writeJsonBody(serializeBinding(b), 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      UpdateServiceBindingRequest r;
      r.description = j.getString("description");
      r.secretName = j.getString("secretName");
      r.parametersJson = j.getString("parameters");
      r.labels = jsonStrMap(j, "labels");

      auto result = uc.updateBinding(ServiceBindingId(id), r);
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
      auto result = uc.deleteBinding(ServiceBindingId(id));
      if (result.success)
        res.writeBody("", 204);
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private Json serializeBinding(ServiceBinding b) {
    return Json.emptyObject
    .set("id", b.id)
    .set("serviceInstanceId", b.serviceInstanceId)
    .set("namespaceId", b.namespaceId)
    .set("environmentId", b.environmentId)
    .set("tenantId", b.tenantId)
    .set("name", b.name)
    .set("description", b.description)
    .set("status", b.status.to!string)
    .set("secretName", b.secretName)
    .set("secretNamespace", b.secretNamespace)
    .set("parameters", b.parametersJson)
    .set("labels", b.labels)
    .set("createdBy", b.createdBy)
    .set("createdAt", b.createdAt)
    .set("updatedAt", b.updatedAt);
  }
}
