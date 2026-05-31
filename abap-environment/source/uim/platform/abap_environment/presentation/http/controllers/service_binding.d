/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.presentation.http.controllers.service_binding;
// 
// 
// import uim.platform.abap_environment.application.usecases.manage.service_bindings;
// import uim.platform.abap_environment.application.dto;
// import uim.platform.abap_environment.domain.entities.service_binding;


import uim.platform.abap_environment;

// mixin(ShowModule!());
@safe:

class ServiceBindingController : ManageController {
  private ManageServiceBindingsUseCase usecase;

  this(ManageServiceBindingsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/service-bindings", &handleCreate);
    router.get("/api/v1/service-bindings", &handleList);
    router.get("/api/v1/service-bindings/*", &handleGet);
    router.put("/api/v1/service-bindings/*", &handleUpdate);
    router.delete_("/api/v1/service-bindings/*", &handleDelete);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto tenantId = precheck.tenantId;
    auto systemId = SystemInstanceId(req.headers.get("X-System-Id", ""));

    auto bindings = usecase.listServiceBindings(tenantId, systemId);
    auto arr = bindings.map!(b => b.toJson).array.toJson;

    return Json.emptyObject
      .set("items", arr)
      .set("totalCount", bindings.length)
      .set("status", 200)
      .set("message", "Service bindings retrieved successfully");
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    CreateServiceBindingRequest r;
    r.tenantId = tenantId;
    r.systemInstanceId = data.getString("systemInstanceId");
    r.serviceDefinitionId = data.getString("serviceDefinitionId");
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.bindingType = data.getString("bindingType");

    auto result = usecase.createServiceBinding(r);
    if (result.hasError()) {
      return Json.emptyObject
        .set("status", 400)
        .set("error", result.message)
        .set("message", "Failed to create service binding");
    }
    return Json.emptyObject
      .set("id", result.id)
      .set("status", 201)
      .set("message", "Service binding created");
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto tenantId = precheck.tenantId;
    auto id = ServiceBindingId(precheck.id);

    auto binding = usecase.getServiceBinding(tenantId, id);
    if (binding.isNull) {
      return Json.emptyObject
        .set("status", 404)
        .set("error", "Service binding not found")
        .set("message", "Service binding not found");
    }
    return Json.emptyObject
      .set("item", binding.toJson)
      .set("status", 200)
      .set("message", "Service binding retrieved successfully");
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto tenantId = precheck.tenantId;
    auto id = ServiceBindingId(precheck.id);
    auto data = precheck.data;

    UpdateServiceBindingRequest r;
    r.tenantId = tenantId;
    r.serviceBindingId = id;
    r.description = data.getString("description");
    r.status = data.getString("status");

    auto result = usecase.updateServiceBinding(r);
    if (result.hasError()) {
      return Json.emptyObject
        .set("status", 404)
        .set("error", result.message)
        .set("message", "Service binding not found");
    }
    return Json.emptyObject
      .set("status", 200)
      .set("message", "Service binding updated");
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto tenantId = precheck.tenantId;
    auto id = ServiceBindingId(precheck.id);

    auto result = usecase.deleteServiceBinding(tenantId, id);
    if (result.hasError()) {
      return Json.emptyObject
        .set("status", 404)
        .set("error", result.message)
        .set("message", "Service binding not found");
    }
    return Json.emptyObject
      .set("status", 200)
      .set("message", "Service binding deleted");
  }
}
