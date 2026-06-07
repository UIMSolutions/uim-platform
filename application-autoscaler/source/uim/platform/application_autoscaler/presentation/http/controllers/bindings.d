/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.presentation.http.controllers.bindings;

import uim.platform.application_autoscaler;

// mixin(ShowModule!());

@safe:

class AppBindingController : ManageHttpController {
  private ManageAppBindingsUseCase usecase;

  this(ManageAppBindingsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/bindings", &handleCreate);
    router.get("/api/v1/bindings", &handleList);
    router.get("/api/v1/bindings/*", &handleGet);
    router.delete_("/api/v1/bindings/*", &handleDelete);
    router.post("/api/v1/bindings/*/policy", &handleAttachPolicy);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto bindings = usecase.listBindings(tenantId);
    auto arr = bindings.map!(b => b.toJson()).array.toJson;

    auto response = json.emptyObject
      .set("items", arr)
      .set("totalCount", bindings.length);

    return successResponse("Bindings retrieved successfully", "Retrieved", 200, response);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateAppBindingRequest r;
    r.tenantId = data.getString("tenant_id");
    r.appGuid = data.getString("app_guid");
    r.appName = data.getString("app_name");
    r.serviceInstanceId = data.getString("service_instance_id");

    auto result = usecase.createBinding(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Binding created successfully", "Created", 201, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = AppBindingId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid binding ID", 400);

    auto binding = usecase.getBinding(tenantId, id);
    if (binding.isNull)
      return errorResponse("Binding not found", 404);

    auto responseData = binding.toJson();
    return successResponse("Binding retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = AppBindingId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid binding ID", 400);

    auto data = precheck.data;
    auto policyId = data.getString("policy_id");
    auto result = usecase.attachPolicy(tenantId, id, policyId);

    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Policy attached successfully", "Attached", 200, responseData);
  }
}
