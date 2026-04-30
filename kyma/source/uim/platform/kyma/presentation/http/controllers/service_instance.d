/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.presentation.http.controllers.service_instance;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

// import uim.platform.kyma.application.usecases.manage.service_instances;
// import uim.platform.kyma.application.dto;
// import uim.platform.kyma.domain.entities.service_instance;
// import uim.platform.kyma.domain.types;
// import uim.platform.kyma.presentation.http.json_utils;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
class ServiceInstanceController : PlatformController {
  private ManageServiceInstancesUseCase uc;

  this(ManageServiceInstancesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/service-instances", &handleCreate);
    router.get("/api/v1/service-instances", &handleList);
    router.get("/api/v1/service-instances/*", &handleGetById);
    router.put("/api/v1/service-instances/*", &handleUpdate);
    router.delete_("/api/v1/service-instances/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateServiceInstanceRequest r;
      r.namespaceId = j.getString("namespaceId");
      r.environmentId = j.getString("environmentId");
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.serviceOfferingName = j.getString("serviceOfferingName");
      r.servicePlanName = j.getString("servicePlanName");
      r.servicePlanId = j.getString("servicePlanId");
      r.externalName = j.getString("externalName");
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
      auto envId = req.params.get("environmentId");

      ServiceInstance[] items;
      if (nsId.length > 0)
        items = uc.listByNamespace(NamespaceId(nsId));
      else if (envId.length > 0)
        items = uc.listByEnvironment(KymaEnvironmentId(envId));
      else
        items = [];

      auto arr = Json.emptyArray;
      foreach (inst; items)
        arr ~= serializeInst(inst);

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
      auto inst = uc.getServiceInstance(ServiceInstanceId(id));
      if (inst.id.isEmpty) {
        writeError(res, 404, "Service instance not found");
        return;
      }
      res.writeJsonBody(serializeInst(inst), 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      UpdateServiceInstanceRequest r;
      r.description = j.getString("description");
      r.servicePlanName = j.getString("servicePlanName");
      r.servicePlanId = j.getString("servicePlanId");
      r.parametersJson = j.getString("parameters");
      r.labels = jsonStrMap(j, "labels");

      auto result = uc.updateServiceInstance(ServiceInstanceId(id), r);
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
      auto result = uc.deleteServiceInstance(ServiceInstanceId(id));
      if (result.success)
        res.writeBody("", 204);
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private Json serializeInst(ServiceInstance inst) {
    return Json.emptyObject
     .set("id", inst.id)
     .set("namespaceId", inst.namespaceId)
     .set("environmentId", inst.environmentId)
     .set("tenantId", inst.tenantId)
     .set("name", inst.name)
     .set("description", inst.description)
     .set("status", inst.status.to!string)
     .set("serviceOfferingName", inst.serviceOfferingName)
     .set("servicePlanName", inst.servicePlanName)
     .set("servicePlanId", inst.servicePlanId)
     .set("externalName", inst.externalName)
     .set("parameters", inst.parametersJson)
     .set("labels", serializeStrMap(inst.labels))
     .set("bindingCount", inst.bindingCount)
     .set("createdBy", inst.createdBy)
     .set("createdAt", inst.createdAt)
     .set("updatedAt", inst.updatedAt);
  }
}
