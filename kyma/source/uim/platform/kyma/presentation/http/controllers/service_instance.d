/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.presentation.http.controllers.service_instance;



// import uim.platform.kyma.application.usecases.manage.service_instances;
// import uim.platform.kyma.application.dto;
// import uim.platform.kyma.domain.entities.service_instance;
// import uim.platform.kyma.domain.types;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
class ServiceInstanceController : ManageController {
  private ManageServiceInstancesUseCase usecase;

  this(ManageServiceInstancesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/service-instances", &handleCreate);
    router.get("/api/v1/service-instances", &handleList);
    router.get("/api/v1/service-instances/*", &handleGet);
    router.put("/api/v1/service-instances/*", &handleUpdate);
    router.delete_("/api/v1/service-instances/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateServiceInstanceRequest r;
      r.tenantId = tenantId;
      r.namespaceId = j.getString("namespaceId");
      r.environmentId = j.getString("environmentId");
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.serviceOfferingName = j.getString("serviceOfferingName");
      r.servicePlanName = j.getString("servicePlanName");
      r.servicePlanId = j.getString("servicePlanId");
      r.externalName = j.getString("externalName");
      r.parametersJson = j.getString("parameters");
      r.labels = jsonStrMap(j, "labels");
      r.createdBy = UserId(req.headers.get("X-User-Id", ""));

      auto result = usecase.create(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto nsId = NamespaceId(req.params.get("namespaceId"));
      auto envId = KymaEnvironmentId(req.params.get("environmentId"));

      ServiceInstance[] items;
      if (!nsId.isEmpty)
        items = usecase.listByNamespace(tenantId, nsId);
      else if (!envId.isEmpty)
        items = usecase.listByEnvironment(tenantId, envId);

      auto arr = items.map!(inst => inst.toJson).array.toJson;
      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length)
        .set("message", "Service instances retrieved successfully");
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI);
      auto inst = usecase.getServiceInstance(tenantId, id);
      if (inst.isNull) {
        writeError(res, 404, "Service instance not found");
        return;
      }
      res.writeJsonBody(inst.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = ServiceInstanceId(tenantId, extractIdFromPath(
          req.requestURI));
      auto j = req.json;
      UpdateServiceInstanceRequest r;
      r.tenantId = tenantId;
      r.serviceInstanceId = id;
      r.description = j.getString(
        "description");
      r.servicePlanName = j.getString("servicePlanName");
      r.servicePlanId = j.getString("servicePlanId");
      r.parametersJson = j.getString(
        "parameters");
      r.labels = jsonStrMap(j, "labels");
      auto result = usecase.updateServiceInstance(
        r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = ServiceInstanceId(
        extractIdFromPath(req.requestURI));
      auto result = usecase.deleteServiceInstance(tenantId, id);
      if (result.success)
        res.writeBody("", 204);
      else
        writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

}
