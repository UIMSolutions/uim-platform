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
    auto items = usecase.listBindings(tenantId);
    return Json.emptyObject
        .set("items", items.map!(b => b.toJson).array.toJson)
        .set("totalCount", Json(items.length))
        .set("message", "Service bindings retrieved successfully")
        .set("statusCode", 200);
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
      return Json.emptyObject.set("message", result.message).set("statusCode", 400);
    return Json.emptyObject
        .set("id", result.id)
        .set("message", "Service binding created")
        .set("statusCode", 201);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto tenantId = precheck.tenantId;
    auto id = ServiceBindingId(precheck.id);
    auto binding = usecase.getBinding(tenantId, id);
    if (binding.id.value.length == 0)
      return Json.emptyObject.set("message", "Service binding not found").set("statusCode", 404);
    return binding.toJson.set("message", "Service binding retrieved").set("statusCode", 200);
  }

  // No update for bindings (immutable after creation)
  override protected Json updateHandler(HTTPServerRequest req) {
    return Json.emptyObject.set("message", "Bindings are immutable").set("statusCode", 405);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto tenantId = precheck.tenantId;
    auto id = ServiceBindingId(precheck.id);
    auto result = usecase.deleteBinding(tenantId, id);
    if (result.hasError()) {
      auto code = result.message == "Service binding not found" ? 404 : 400;
      return Json.emptyObject.set("message", result.message).set("statusCode", code);
    }
    return Json.emptyObject.set("id", result.id).set("message", "Service binding deleted").set("statusCode", 200);
  }
}
