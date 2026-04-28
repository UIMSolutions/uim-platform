/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.http.controllers.service_binding;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// // import std.conv : to;
// 
// import uim.platform.abap_environment.application.usecases.manage.service_bindings;
// import uim.platform.abap_environment.application.dto;
// import uim.platform.abap_environment.domain.entities.service_binding;
// import uim.platform.abap_environment.domain.types;

import uim.platform.abap_environment;

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
      r.tenantId = req.getTenantId;
      r.systemInstanceId = j.getString("systemInstanceId");
      r.serviceDefinitionId = j.getString("serviceDefinitionId");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.bindingType = j.getString("bindingType");

      auto result = uc.createBinding(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto systemId = req.headers.get("X-System-Id", "");
      auto bindings = uc.listBindings(systemId);
      auto arr = Json.emptyArray;
      foreach (b; bindings)
        arr ~= serializeBinding(b);
      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(bindings.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto binding = uc.getBinding(id);
      if (binding.isNull) {
        writeError(res, 404, "Service binding not found");
        return;
      }
      res.writeJsonBody(serializeBinding(*binding), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      UpdateServiceBindingRequest r;
      r.description = j.getString("description");
      r.status = j.getString("status");

      auto result = uc.updateBinding(id, r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["status"] = Json("updated");
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.deleteBinding(id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["status"] = Json("deleted");
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeBinding(const ServiceBinding b) {
    auto j = Json.emptyObject
      .set("id", b.id)
      .set("tenantId", b.tenantId)
      .set("systemInstanceId", b.systemInstanceId)
      .set("serviceDefinitionId", b.serviceDefinitionId)
      .set("name", b.name)
      .set("description", b.description)
      .set("bindingType", b.bindingType.to!string)
      .set("status", b.status.to!string)
      .set("serviceUrl", b.serviceUrl)
      .set("metadataUrl", b.metadataUrl)
      .set("createdAt", b.createdAt)
      .set("updatedAt", b.updatedAt);

    if (b.endpoints.length > 0) {
      auto eps = Json.emptyArray;
      foreach (ep; b.endpoints) {
        eps ~= Json.emptyObject
        .set("path", ep.path)
        .set("serviceName", ep.serviceName)
        .set("serviceVersion", ep.serviceVersion)
        .set("requiresAuth", ep.requiresAuth);
      }
      j["endpoints"] = eps;
    }

    return j;
  }
}
