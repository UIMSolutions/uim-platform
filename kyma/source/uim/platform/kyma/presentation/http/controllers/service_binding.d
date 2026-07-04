/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.presentation.http.controllers.service_binding;

// import uim.platform.kyma.application.usecases.manage.service_bindings;
// import uim.platform.kyma.application.dto;
// import uim.platform.kyma.domain.entities.service_binding;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:
class ServiceBindingController : ManageHttpController {
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

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateServiceBindingRequest r;
    r.tenantId = tenantId;
    r.serviceInstanceId = data.getString("serviceInstanceId");
    r.namespaceId = data.getString("namespaceId");
    r.environmentId = data.getString("environmentId");
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.secretName = data.getString("secretName");
    r.secretNamespace = data.getString("secretNamespace");
    r.parametersJson = data.getString("parameters");
    r.labels = data.jsonStrMap("labels");
    r.createdBy = UserId(req.headers.get("X-User-Id", ""));

    auto result = usecase.create(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject.set("id", result.id);

    return successResponse("Service binding created successfully", 201, resp);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto nsId = NamespaceId(req.params.get("namespaceId"));
    auto instId = ServiceInstanceId(req.params.get("serviceInstanceId"));

    ServiceBinding[] items;
    if (!instId.isEmpty)
      items = usecase.listServiceBindings(tenantId, instId);
    else if (!nsId.isEmpty)
      items = usecase.listServiceBindings(tenantId, nsId);

    auto arr = items.map!(b => b.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", items.length);

    return successResponse("Service binding list retrieved successfully", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ServiceBindingId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid service binding ID", 400);

    auto b = usecase.getBinding(tenantId, id);
    if (b.isNull)
      return errorResponse("Service binding not found", 404);

    auto resp = b.toJson;
    return successResponse("Service binding retrieved successfully", 200, resp);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ServiceBindingId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid service binding ID", 400);

    auto data = precheck.data;
    UpdateServiceBindingRequest r;
    r.tenantId = tenantId;
    r.serviceBindingId = id;
    r.description = data.getString("description");
    r.secretName = data.getString("secretName");
    r.parametersJson = data.getString("parameters");
    r.labels = data.jsonStrMap("labels");

    auto result = usecase.updateBinding(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Service binding updated successfully", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ServiceBindingId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid service binding ID", 400);

    auto result = usecase.deleteBinding(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Service binding deleted successfully", 200, responseData);
  }
}
