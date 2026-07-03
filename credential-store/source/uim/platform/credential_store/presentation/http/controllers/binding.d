/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.presentation.http.controllers.binding;
// import uim.platform.credential_store.application.usecases.manage.service_bindings;
// import uim.platform.credential_store.application.dto;

import uim.platform.credential_store;

// mixin(ShowModule!());

@safe:

class BindingController : ManageHttpController {
  private ManageServiceBindingsUseCase bindings;

  this(ManageServiceBindingsUseCase bindings) {
    this.bindings = bindings;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/bindings", &handleCreate);
    router.get("/api/v1/bindings", &handleList);
    router.get("/api/v1/bindings/*", &handleGet);
    router.put("/api/v1/bindings/*", &handleUpdate);
    router.delete_("/api/v1/bindings/*", &handleDelete);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto bindings = this.bindings.listServiceBindings(tenantId);

    auto jarr = Json.emptyArray;
    foreach (b; bindings) {
      jarr ~= Json.emptyObject
        .set("entity", "ServiceBinding")
        .set("id", b.id)
        .set("name", b.name)
        .set("description", b.description)
        .set("clientId", b.clientId)
        .set("allowedNamespaces", b.allowedNamespaces.map!(ns => ns.value)
            .array.toJson)
        .set("createdAt", b.createdAt)
        .set("expiresAt", b.expiresAt);
    }

    return successResponse("Service bindings retrieved successfully", 200,
      Json.emptyObject.set("count", bindings.length).set("items", jarr));
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    CreateServiceBindingRequest r;
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.permission = data.getString("permission");
    r.allowedNamespaces = data.getArray("allowedNamespaces")
      .map!(ns => NamespaceId(ns.getString)).array;
    r.expiresAt = data.getLong("expiresAt");
    r.createdBy = UserId(data.getString("createdBy"));

    auto binding = bindings.createServiceBinding(r);
    if (binding.bindingId.isNull)
      return errorResponse("Failed to create service binding", 400);

    // Return binding credentials (only shown once at creation)
    auto resp = Json.emptyObject
      .set("entity", "ServiceBinding")
      .set("id", binding.bindingId)
      .set("name", binding.name)
      .set("clientId", binding.clientId)
      .set("clientSecret", binding.clientSecret)
      .set("permission", binding.permission)
      .set("status", binding.status)
      .set("allowedNamespaces", toJsonArray(binding.allowedNamespaces))
      .set("createdAt", binding.createdAt)
      .set("expiresAt", binding.expiresAt);

    return successResponse("Service binding created successfully", 201, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ServiceBindingId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid Service Binding ID", 400);

    auto b = bindings.getServiceBinding(tenantId, id);
    if (b.isNull)
      return errorResponse("Service binding not found", 404);

    auto response = Json.emptyObject
      .set("id", b.id)
      .set("name", b.name)
      .set("description", b.description)
      .set("clientId", b.clientId)
      .set("allowedNamespaces", b.allowedNamespaces.map!(ns => ns.value)
          .array.toJson)
      .set("createdAt", b.createdAt)
      .set("expiresAt", b.expiresAt);

    return successResponse("Service binding retrieved successfully", 200, response);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ServiceBindingId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid Service Binding ID", 400);

    auto data = precheck.data;

    UpdateServiceBindingRequest r;
    r.bindingId = id;
    r.tenantId = tenantId;
    r.description = data.getString("description");
    r.permission = data.getString("permission");
    r.status = data.getString("status");
    r.allowedNamespaces = data.getArray("allowedNamespaces")
      .map!(ns => NamespaceId(ns.getString)).array;

    auto result = bindings.updateServiceBinding(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("Service binding updated successfully", 200,
      Json.emptyObject.set("id", result.id));
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ServiceBindingId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid Service Binding ID", 400);

    auto result = bindings.deleteServiceBinding(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("Service binding deleted successfully", 204, Json.emptyObject);
  }
}
