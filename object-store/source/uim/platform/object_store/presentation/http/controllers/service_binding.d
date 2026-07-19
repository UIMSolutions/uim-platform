/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.presentation.http.controllers.service_binding;

// import uim.platform.object_store.application.usecases.manage.service_bindings;
// import uim.platform.object_store.application.dto;
// import uim.platform.object_store.domain.entities.service_binding;
import uim.platform.object_store;

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
    router.get("/api/v1/buckets/*/service-bindings", &handleListByBucket);
    router.get("/api/v1/service-bindings/*", &handleGet);
    router.post("/api/v1/service-bindings/*/revoke", &handleRevoke);
    router.delete_("/api/v1/service-bindings/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    auto request = CreateServiceBindingRequest();
    request.tenantId = tenantId;
    request.bucketId = data.getString("bucketId");
    request.name = data.getString("name");
    request.permission = data.getString("permission");
    request.expiresAt = data.getLong("expiresAt");
    request.createdBy = UserId(req.headers.get("X-User-Id", ""));

    auto result = usecase.createBinding(request);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("id", result.id)
      .set("message", "Service binding created");

    return successResponse("Service binding created successfully", 201, resp);
  }

  protected Json listByBucketHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto bucketId = BucketId(extractBucketIdFromBindingsPath(req.requestURI));
    if (bucketId.isEmpty)
      return errorResponse("Invalid bucket ID in path");

    auto bindings = usecase.listBindings(tenantId, bucketId);
    auto arr = bindings.map!(b => b.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", bindings.length)
      .set("message", "Service bindings retrieved successfully");

    return successResponse("Service bindings retrieved successfully", 200, resp);
  }

  mixin(HandleTemplate!("handleListByBucket", "listByBucketHandler"));

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto path = precheck.path;

    auto id = precheck.id;
    if (id == "revoke")
      return errorResponse("Invalid service binding ID", 400);

    auto binding = usecase.getBinding(tenantId, ServiceBindingId(id));
    if (binding.isNull)
      return errorResponse("Service binding not found", 404);

    return successResponse("Service binding retrieved successfully", 200, binding.toJson);
  }

  protected Json revokeHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    // /api/v1/service-bindings/{id}/revoke
    auto path = req.requestURI;
    // import std.string : indexOf;
    auto bindingsPos = path.indexOf("service-bindings/");
    if (bindingsPos < 0) 
      return errorResponse("Invalid URI format", 400);
    
    auto start = bindingsPos + 17; // length of "service-bindings/"
    auto rest = path[start .. $];
    auto slashPos = rest.indexOf('/');
    auto id = ServiceBindingId(slashPos > 0 ? rest[0 .. slashPos] : rest);
    if (id.isNull)
      return errorResponse("Invalid service binding ID", 400);

    auto result = usecase.revokeBinding(tenantId, (id));
    if (result.hasError)
      return errorResponse(result.message, 400);
    
    auto resp = Json.emptyObject
      .set("revoked", true)
      .set("message", "Service binding revoked");
    return successResponse("Service binding revoked successfully", "Revoked", 200, resp);
  }

  mixin(HandleTemplate!("handleRevoke", "revokeHandler"));

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ServiceBindingId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid service binding ID", 400);

    auto result = usecase.deleteBinding(tenantId, (id));
    if (result.hasError)
      return errorResponse(result.message, 404);

    auto response = Json.emptyObject
      .set("deleted", true);

    return successResponse("Service binding deleted successfully", 200, response);
  }

  private static string extractBucketIdFromBindingsPath(string uri) {
    // import std.string : indexOf;
    auto qpos = uri.indexOf('?');
    string path = qpos >= 0 ? uri[0 .. qpos] : uri;

    auto bucketsPos = path.indexOf("buckets/");
    if (bucketsPos < 0)
      return "";
    auto start = bucketsPos + 8;
    auto rest = path[start .. $];
    auto slashPos = rest.indexOf('/');
    if (slashPos > 0)
      return rest[0 .. slashPos];
    return rest;
  }
}
