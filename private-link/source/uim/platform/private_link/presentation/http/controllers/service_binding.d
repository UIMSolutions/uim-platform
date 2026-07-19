/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.private_link.presentation.http.controllers.service_binding;
import uim.platform.private_link;
mixin(ShowModule!());

@safe:
/// HTTP controller for service binding management.
class ServiceBindingController : ManageHttpController {
  private ManageServiceBindingsUseCase usecase;

  this(ManageServiceBindingsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/service-bindings",      &handleCreate);
    router.get("/api/v1/service-bindings",       &handleList);
    router.get("/api/v1/service-bindings/*",     &handleGet);
    router.delete_("/api/v1/service-bindings/*", &handleDelete);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto tenantId = precheck.tenantId;
    auto items = usecase.listBindings(tenantId).map!(b => b.toJson).array;
    return successResponse("Service bindings retrieved successfully", "Retrieved", 200,
     Json.emptyObject
        .set("items", items)
        .set("totalCount", items.length));
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    auto r = CreateServiceBindingRequest();
    r.tenantId = tenantId;
    r.serviceInstanceId = ServiceInstanceId(data.getString("serviceInstanceId"));
    r.applicationId = data.getString("applicationId");

    auto result = usecase.createBinding(r);
    if (result.hasError())
      return errorResponse(result.message, 400);

    return successResponse("Service binding created", "Created", 201, Json.emptyObject
        .set("id", result.id));
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto tenantId = precheck.tenantId;
    auto id = ServiceBindingId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid service binding ID", 400);

    auto binding = usecase.getBinding(tenantId, id);
    if (binding.id.value.length == 0)
      return errorResponse("Service binding not found", 404);

    return successResponse("Service binding retrieved", "Retrieved", 200, binding.toJson
        .set("status", "success")
        .set("statusCode", 200));
  }

  // No update for bindings (immutable after creation)
  override protected Json updateHandler(HTTPServerRequest req) {
    return Json.emptyObject.set("message", "Bindings are immutable").set("statusCode", 405);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto tenantId = precheck.tenantId;
    auto id = ServiceBindingId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid service binding ID", 400);

    auto result = usecase.deleteBinding(tenantId, id);
    if (result.hasError()) 
      return errorResponse(result.message, result.message == "Service binding not found" ? 404 : 400);

    return successResponse("Service binding deleted", "Deleted", 200, Json.emptyObject
        .set("id", result.id));
  }
}
