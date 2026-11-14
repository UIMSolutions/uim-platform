/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.presentation.http.controllers.app_version;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// REST adapter for app versions:
///   GET/POST {base}/app-versions   GET/PUT/DELETE {base}/app-versions/:id
class AppVersionController : ManageHttpController {
  protected IManageAppVersionsUseCase usecase;
  protected string basePath;

  this(IManageAppVersionsUseCase usecase, string apiPath = "/api/v1/agentry") {
    this.usecase = usecase;
    this.basePath = apiPath.stripRight("/") ~ "/app-versions";
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

    auto items = usecase.listAppVersions(precheck.tenantId);
    auto resp = Json.emptyObject
      .set("count", items.length)
      .set("resources", items.map!(e => e.toJson()).array.toJson);
    return successResponse("App version list retrieved", "Retrieved", 200, resp);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    AppVersionDTO dto;
    try
      readPayload(dto, precheck.data);
    catch (PayloadException e)
      return errorResponse(e.msg, 400);
    dto.tenantId = precheck.tenantId;
    dto.createdBy = UserId(req.headers.get("X-User-Id", ""));

    auto result = usecase.createAppVersion(dto);
    if (!result.isSuccess)
      return errorResponse(result.message, httpStatusOf(result));
    return successResponse(result.message, "Created", 201, Json.emptyObject.set("id", result.id));
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto id = AppVersionId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid app version ID", 400);
    auto entity = usecase.getAppVersion(precheck.tenantId, id);
    if (entity.isNull)
      return errorResponse("App version not found", 404);
    return successResponse("App version retrieved", "Retrieved", 200, entity.toJson);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto id = AppVersionId(precheck.id);
    auto current = usecase.getAppVersion(precheck.tenantId, id);
    if (current.isNull)
      return errorResponse("App version not found", 404);

    // merge: start from the stored values, overlay the supplied ones
    auto dto = AppVersionDTO.fromEntity(current);
    try
      readPayload(dto, precheck.data);
    catch (PayloadException e)
      return errorResponse(e.msg, 400);
    dto.versionId = id;
    dto.tenantId = precheck.tenantId;
    dto.updatedBy = UserId(req.headers.get("X-User-Id", ""));

    auto result = usecase.updateAppVersion(dto);
    if (!result.isSuccess)
      return errorResponse(result.message, httpStatusOf(result));
    return successResponse(result.message, "Updated", 200, Json.emptyObject.set("id", result.id));
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto id = AppVersionId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid app version ID", 400);
    auto result = usecase.deleteAppVersion(precheck.tenantId, id);
    if (!result.isSuccess)
      return errorResponse(result.message, httpStatusOf(result));
    return successResponse(result.message, "Deleted", 200, Json.emptyObject.set("id", id.value));
  }
}
