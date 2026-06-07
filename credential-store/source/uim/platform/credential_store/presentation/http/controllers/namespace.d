/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.presentation.http.controllers.namespace;
// import uim.platform.credential_store.application.usecases.manage.usecase;
// import uim.platform.credential_store.application.dto;

import uim.platform.credential_store;

// mixin(ShowModule!());

@safe:

class NamespaceController : ManageHttpController {
  private ManageNamespacesUseCase usecase;

  this(ManageNamespacesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/usecase", &handleCreate);
    router.get("/api/v1/usecase", &handleList);
    router.get("/api/v1/usecase/*", &handleGet);
    router.put("/api/v1/usecase/*", &handleUpdate);
    router.delete_("/api/v1/usecase/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateNamespaceRequest r;
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.createdBy = UserId(data.getString("createdBy"));

    auto result = usecase.createNamespace(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Namespace created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto namespaces = usecase.listNamespaces(tenantId);
    auto list = Json.emptyArray;
    foreach (ns; namespaces) {
      list ~= Json.emptyObject
        .set("id", ns.id)
        .set("name", ns.name)
        .set("description", ns.description)
        .set("createdAt", ns.createdAt);
    }

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Namespace list retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = NamespaceId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid namespace ID", 400);

    auto ns = usecase.getNamespace(tenantId, id);
    if (ns.isNull)
      return errorResponse("Namespace not found", 404);

    auto responseData = ns.toJson();
    return successResponse("Namespace retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = NamespaceId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid namespace ID", 400);
      
    auto data = precheck.data;
    UpdateNamespaceRequest request;
    request.tenantId = tenantId;
    request.namespaceId = id;
    request.description = data.getString("description");

    auto result = usecase.updateNamespace(request);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Namespace updated successfully", "Updated", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = NamespaceId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid namespace ID", 400);

    auto result = usecase.deleteNamespace(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Namespace deleted successfully", "Deleted", 200, responseData);
  }
}
