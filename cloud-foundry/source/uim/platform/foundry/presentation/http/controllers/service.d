/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.presentation.http.controllers.service;






// import uim.platform.foundry.application.usecases.manage.services;
// import uim.platform.foundry.application.dto;
// import uim.platform.foundry.domain.types;
// import uim.platform.foundry.domain.entities.service_instance;
// import uim.platform.foundry.domain.entities.service_binding;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:

class ServiceController : ManageController {
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

  override protected void handleCreateInstance(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto r = CreateServiceInstanceRequest();
      r.tenantId = tenantId;
      r.spaceId = SpaceId(data.getString("spaceId"));
      r.name = data.getString("name");
      r.serviceName = data.getString("serviceName");
      r.servicePlanName = data.getString("servicePlanName");
      r.parameters = data.getString("parameters");
      r.tags = data.getString("tags");
      r.createdBy = UserId(data.getString("createdBy"));

      auto result = useCase.createInstance(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Service instance created");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleListInstances(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto items = useCase.listInstances(tenantId);

      auto arr = items.map!(si => si.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length)
        .set("message", "Service instances retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGetGetInstance(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = ServiceInstanceId(precheck.id);
      auto tenantId = precheck.tenantId;
      auto si = useCase.getInstance(tenantId, id);
      if (si.isNull) {
        writeError(res, 404, "Service instance not found");
        return;
      }
      auto resp = si.toJson
        .set("message", "Service instance retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdateInstance(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = ServiceInstanceId(precheck.id);
      auto data = precheck.data;
      auto r = UpdateServiceInstanceRequest();
      r.id = id;
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.parameters = data.getString("parameters");
      r.tags = data.getString("tags");

      auto result = useCase.updateInstance(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Service instance updated");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDeleteInstance(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = ServiceInstanceId(precheck.id);
      auto tenantId = precheck.tenantId;
      auto result = useCase.deleteInstance(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Service instance deleted");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  // --- Service Bindings ---

  override protected void handleCreateBinding(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto r = CreateServiceBindingRequest();
      r.tenantId = tenantId;
      r.appId = AppId(data.getString("appId"));
      r.serviceInstanceId = ServiceInstanceId(data.getString("serviceInstanceId"));
      r.name = data.getString("name");
      r.bindingOptions = data.getString("bindingOptions");
      r.createdBy = UserId(data.getString("createdBy"));

      auto result = useCase.createBinding(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Service binding created");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleListBindings(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto items = useCase.listBindings(tenantId);

      auto arr = items.map!(b => b.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length)
        .set("message", "Service bindings retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDeleteBinding(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = ServiceBindingId(precheck.id);
      auto tenantId = precheck.tenantId;
      auto result = useCase.deleteBinding(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Service binding deleted");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

}
