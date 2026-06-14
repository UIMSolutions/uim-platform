/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.presentation.http.controllers.namespace;

// import uim.platform.kyma.application.usecases.manage.namespaces;
// import uim.platform.kyma.application.dto;
// import uim.platform.kyma.domain.entities.namespace;

import uim.platform.kyma;

// mixin(ShowModule!());

@safe:
class NamespaceController : ManageHttpController {
  private ManageNamespacesUseCase usecase;

  this(ManageNamespacesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/namespaces", &handleCreate);
    router.get("/api/v1/namespaces", &handleList);
    router.get("/api/v1/namespaces/*", &handleGet);
    router.put("/api/v1/namespaces/*", &handleUpdate);
    router.delete_("/api/v1/namespaces/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateNamespaceRequest r;
    r.environmentId = data.getString("environmentId");
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.cpuLimit = data.getString("cpuLimit");
    r.memoryLimit = data.getString("memoryLimit");
    r.cpuRequest = data.getString("cpuRequest");
    r.memoryRequest = data.getString("memoryRequest");
    r.podLimit = data.getInteger("podLimit");
    r.quotaEnforcement = data.getString("quotaEnforcement");
    r.istioInjection = data.getBoolean("istioInjection", true);
    r.labels = data.jsonStrMap("labels");
    r.annotations = data.jsonStrMap("annotations");
    r.createdBy = UserId(req.headers.get("X-User-Id", ""));

    auto result = usecase.create(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject.set("id", result.id);

    return successResponse("Namespace created successfully", 201, resp);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto envIdParam = req.params.get("environmentId");
    string envId = envIdParam.length > 0 ? envIdParam : req.headers.get("X-Environment-Id", "");

    auto items = usecase.listByEnvironment(KymaEnvironmentId(envId));
    auto arr = items.map!(ns => ns.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", items.length);

    return successResponse("Namespaces retrieved successfully", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = precheck.id;
    auto ns = usecase.getNamespace(NamespaceId(id));
    if (ns.isNull)
      return errorResponse("Namespace not found", 404);

    auto responseData = ns.toJson();
    return successResponse("Namespace retrieved successfully", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = NamespaceId(precheck.id);
    if (id.isNull)
      return errorResponse("Namespace not found", 404);

    auto data = precheck.data;
    UpdateNamespaceRequest r;
    r.tenantId = tenantId;
    r.namespaceId = id;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.cpuLimit = data.getString("cpuLimit");
    r.memoryLimit = data.getString("memoryLimit");
    r.cpuRequest = data.getString("cpuRequest");
    r.memoryRequest = data.getString("memoryRequest");
    r.podLimit = data.getInteger("podLimit");
    r.quotaEnforcement = data.getString("quotaEnforcement");
    r.istioInjection = data.getBoolean("istioInjection", true);
    r.labels = data.jsonStrMap("labels");
    r.annotations = data.jsonStrMap("annotations");

    auto result = usecase.updateNamespace(NamespaceId(id), r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("Namespace updated successfully", 200, Json.emptyObject.set("id", id));
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = NamespaceId(precheck.id);
    if (id.isNull)
      return errorResponse("Namespace not found", 404);

    auto result = usecase.deleteNamespace(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("Namespace deleted successfully", 200, Json.emptyObject.set("id", id));

  }
}
