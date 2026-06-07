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

// mixin(ShowModule!());

@safe:

class ServiceController : ManageHttpController {
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
  protected Json createInstanceHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

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
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Service instance created successfully", 201, responseData);
  }

  override protected void handleCreateInstance(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = createInstanceHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json listInstancesHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto items = useCase.listInstances(tenantId);
    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Service instances retrieved successfully", 200, responseData);
  }

  protected void handleListInstances(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = listInstancesHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json getInstanceHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ServiceInstanceId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid service instance ID", 400);

    auto si = useCase.getInstance(tenantId, id);
    if (si.isNull) 
      return errorResponse("Service instance not found", 404);
    
    auto responseData = si.toJson;
    return successResponse("Service instance retrieved successfully", 200, responseData);
  }

  protected void handleGetInstance(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = getInstanceHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json updateInstanceHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ServiceInstanceId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid service instance ID", 400);

    auto data = precheck.data;
    auto r = UpdateServiceInstanceRequest();
    r.id = id;
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.parameters = data.getString("parameters");
    r.tags = data.getString("tags");

    auto result = useCase.updateInstance(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    Json responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Service instance updated successfully", 200, responseData);
  }

  protected void handleUpdateInstance(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = updateInstanceHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json deleteInstanceHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ServiceInstanceId(precheck.id);
    auto result = useCase.deleteInstance(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 404);

  auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Service instance deleted successfully", 200, responseData);
  }

  override protected void handleDeleteInstance(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = deleteInstanceHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  // --- Service Bindings ---
  protected Json createBindingHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

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
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Service binding created successfully", 201, responseData);
  }

  protected void handleCreateBinding(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = createBindingHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json listBindingsHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto items = useCase.listBindings(tenantId);
    auto arr = items.map!(b => b.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("items", arr)
      .set("totalCount", items.length);
    return successResponse("Service bindings retrieved successfully", 200, responseData);
  }

  protected void handleListBindings(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = listBindingsHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json deleteBindingHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ServiceBindingId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid service binding ID", 400);

    auto result = useCase.deleteBinding(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 404);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Service binding deleted successfully", 200, responseData);
  }

  protected void handleDeleteBinding(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = deleteBindingHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
