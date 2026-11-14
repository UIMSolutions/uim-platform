/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.presentation.http.controllers.backend_connection;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// REST adapter for backend connections:
///   GET/POST {base}/backend-connections   GET/PUT/DELETE {base}/backend-connections/:id
class BackendConnectionController : ManageHttpController {
  protected IManageBackendConnectionsUseCase usecase;
  protected string basePath;

  this(IManageBackendConnectionsUseCase usecase, string apiPath = "/api/v1/agentry") {
    this.usecase = usecase;
    this.basePath = apiPath.stripRight("/") ~ "/backend-connections";
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get(basePath, &handleList);
    router.get(basePath ~ "/*", &handleGet);
    router.post(basePath, &handleCreate);
    router.put(basePath ~ "/*", &handleUpdate);
    router.delete_(basePath ~ "/*", &handleDelete);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto items = usecase.listBackendConnections(precheck.tenantId);
    auto resp = Json.emptyObject
      .set("count", items.length)
      .set("resources", items.map!(e => e.toJson()).array.toJson);
    return successResponse("Backend connection list retrieved", "Retrieved", 200, resp);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    BackendConnectionDTO dto;
    try
      readPayload(dto, precheck.data);
    catch (PayloadException e)
      return errorResponse(e.msg, 400);
    dto.tenantId = precheck.tenantId;
    dto.createdBy = UserId(req.headers.get("X-User-Id", ""));

    auto result = usecase.createBackendConnection(dto);
    if (!result.isSuccess)
      return errorResponse(result.message, httpStatusOf(result));
    return successResponse(result.message, "Created", 201, Json.emptyObject.set("id", result.id));
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto id = BackendConnectionId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid backend connection ID", 400);
    auto entity = usecase.getBackendConnection(precheck.tenantId, id);
    if (entity.isNull)
      return errorResponse("Backend connection not found", 404);
    return successResponse("Backend connection retrieved", "Retrieved", 200, entity.toJson);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto id = BackendConnectionId(precheck.id);
    auto current = usecase.getBackendConnection(precheck.tenantId, id);
    if (current.isNull)
      return errorResponse("Backend connection not found", 404);

    // merge: start from the stored values, overlay the supplied ones
    auto dto = BackendConnectionDTO.fromEntity(current);
    try
      readPayload(dto, precheck.data);
    catch (PayloadException e)
      return errorResponse(e.msg, 400);
    dto.connectionId = id;
    dto.tenantId = precheck.tenantId;
    dto.updatedBy = UserId(req.headers.get("X-User-Id", ""));

    auto result = usecase.updateBackendConnection(dto);
    if (!result.isSuccess)
      return errorResponse(result.message, httpStatusOf(result));
    return successResponse(result.message, "Updated", 200, Json.emptyObject.set("id", result.id));
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto id = BackendConnectionId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid backend connection ID", 400);
    auto result = usecase.deleteBackendConnection(precheck.tenantId, id);
    if (!result.isSuccess)
      return errorResponse(result.message, httpStatusOf(result));
    return successResponse(result.message, "Deleted", 200, Json.emptyObject.set("id", id.value));
  }
}
