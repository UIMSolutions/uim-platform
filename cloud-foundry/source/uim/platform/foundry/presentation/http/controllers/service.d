/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.presentation.http.controllers.service;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

import uim.platform.foundry.application.usecases.manage.services;
import uim.platform.foundry.application.dto;
import uim.platform.foundry.domain.types;
import uim.platform.foundry.domain.entities.service_instance;
import uim.platform.foundry.domain.entities.service_binding;

class ServiceController : SAPController {
  private ManageServicesUseCase useCase;

  this(ManageServicesUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    // Service instances
    router.post("/api/v1/service-instances", &handleCreateInstance);
    router.get("/api/v1/service-instances", &handleListInstances);
    router.get("/api/v1/service-instances/*", &handleGetInstance);
    router.put("/api/v1/service-instances/*", &handleUpdateInstance);
    router.delete_("/api/v1/service-instances/*", &handleDeleteInstance);
    // Service bindings
    router.post("/api/v1/service-bindings", &handleCreateBinding);
    router.get("/api/v1/service-bindings", &handleListBindings);
    router.delete_("/api/v1/service-bindings/*", &handleDeleteBinding);
  }

  // --- Service Instances ---

  private void handleCreateInstance(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateServiceInstanceRequest();
      r.tenantId = req.getTenantId;
      r.spaceId = j.getString("spaceId");
      r.name = j.getString("name");
      r.serviceName = j.getString("serviceName");
      r.servicePlanName = j.getString("servicePlanName");
      r.parameters = j.getString("parameters");
      r.tags = j.getString("tags");
      r.createdBy = j.getString("createdBy");

      auto result = useCase.createInstance(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleListInstances(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto items = useCase.listInstances(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref si; items)
        arr ~= serializeInstance(si);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long)items.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetInstance(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.getTenantId;
      auto si = useCase.getInstance(id, tenantId);
      if (si is null) {
        writeError(res, 404, "Service instance not found");
        return;
      }
      res.writeJsonBody(serializeInstance(*si), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdateInstance(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdateServiceInstanceRequest();
      r.id = id;
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.parameters = j.getString("parameters");
      r.tags = j.getString("tags");

      auto result = useCase.updateInstance(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDeleteInstance(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.getTenantId;
      auto result = useCase.deleteInstance(id, tenantId);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  // --- Service Bindings ---

  private void handleCreateBinding(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateServiceBindingRequest();
      r.tenantId = req.getTenantId;
      r.appId = j.getString("appId");
      r.serviceInstanceId = j.getString("serviceInstanceId");
      r.name = j.getString("name");
      r.bindingOptions = j.getString("bindingOptions");
      r.createdBy = j.getString("createdBy");

      auto result = useCase.createBinding(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleListBindings(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto items = useCase.listBindings(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref b; items)
        arr ~= serializeBinding(b);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long)items.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDeleteBinding(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.getTenantId;
      auto result = useCase.deleteBinding(id, tenantId);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  // --- Serializers ---

  private static Json serializeInstance(ref const ServiceInstance si) {
    auto j = Json.emptyObject;
    j["id"] = Json(si.id);
    j["spaceId"] = Json(si.spaceId);
    j["tenantId"] = Json(si.tenantId);
    j["name"] = Json(si.name);
    j["serviceName"] = Json(si.serviceName);
    j["servicePlanName"] = Json(si.servicePlanName);
    j["status"] = Json(si.status.to!string);
    j["parameters"] = Json(si.parameters);
    j["dashboardUrl"] = Json(si.dashboardUrl);
    j["tags"] = Json(si.tags);
    j["createdBy"] = Json(si.createdBy);
    j["createdAt"] = Json(si.createdAt);
    j["updatedAt"] = Json(si.updatedAt);
    return j;
  }

  private static Json serializeBinding(ref const ServiceBinding b) {
    auto j = Json.emptyObject;
    j["id"] = Json(b.id);
    j["appId"] = Json(b.appId);
    j["serviceInstanceId"] = Json(b.serviceInstanceId);
    j["tenantId"] = Json(b.tenantId);
    j["name"] = Json(b.name);
    j["status"] = Json(b.status.to!string);
    j["credentials"] = Json(b.credentials);
    j["bindingOptions"] = Json(b.bindingOptions);
    j["createdBy"] = Json(b.createdBy);
    j["createdAt"] = Json(b.createdAt);
    return j;
  }
}
