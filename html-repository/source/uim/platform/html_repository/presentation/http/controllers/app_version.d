/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.presentation.http.controllers.app_version;
// import uim.platform.html_repository.application.usecases.manage.app_versions;
// import uim.platform.html_repository.application.dto;
// import uim.platform.htmls;

import uim.platform.html_repository;

// mixin(ShowModule!());

@safe:
class AppVersionController : ManageHttpController {
  private ManageAppVersionsUseCase usecase;

  this(ManageAppVersionsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/versions", &handleCreate);
    router.get("/api/v1/versions", &handleList);
    router.get("/api/v1/versions/*", &handleGet);
    router.put("/api/v1/versions/*", &handleUpdate);
    router.delete_("/api/v1/versions/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateAppVersionRequest r;
    r.tenantId = tenantId;
    r.appId = AppVersionId(data.getString("appId"));
    r.versionCode = data.getString("versionCode");
    r.description = data.getString("description");
    r.createdBy = UserId(data.getString("createdBy"));

    auto result = usecase.createAppVersion(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("id", result.id);

    return successResponse("Version created successfully", "Created", 201, resp);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto appId = getString(req.json, "appId");
    if (appId.isEmpty)
      appId = req.headers.get("X-App-Id", "");
    auto items = usecase.listByApp(appId);

    auto arr = Json.emptyArray;
    foreach (e; items) {
      arr ~= Json.emptyObject
        .set("id", Json(e.id))
        .set("appId", Json(e.appId))
        .set("versionCode", Json(e.versionCode))
        .set("status", Json(e.status))
        .set("fileCount", Json(e.fileCount));
    }

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", items.length);

    return successResponse("Versions retrieved successfully", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = precheck.id;
    auto tenantId = precheck.tenantId;
    if (id.isNull)
      return errorResponse("Version not found", 404);

    auto entry = usecase.getById(tenantId, id);
    if (entry.isNull)
      return errorResponse("Version not found", 404);

    auto obj = Json.emptyObject
      .set("id", entry.id)
      .set("appId", entry.appId)
      .set("versionCode", entry.versionCode)
      .set("description", entry.description)
      .set("status", entry.status)
      .set("fileCount", entry.fileCount)
      .set("createdBy", entry.createdBy)
      .set("createdAt", entry.createdAt)
      .set("updatedAt", entry.updatedAt);

    return successResponse("Version retrieved successfully", 200, obj);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = AppVersionId(precheck.id);
    if (id.isNull)
      return errorResponse("Version not found", 404);

    auto data = precheck.data;
    UpdateAppVersionRequest r;
    r.description = data.getString("description");
    r.status = data.getString("status");

    auto result = usecase.update(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("id", id);

    return successResponse("Version updated successfully", "Updated", 200, resp);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = AppVersionId(precheck.id);
    if (id.isNull)
      return errorResponse("Version not found", 404);

    auto tenantId = precheck.tenantId;
    if (id.isNull)
      return errorResponse("Version not found", 404);

    auto result = usecase.deleteAppVersion(tenantId, AppVersionId(id));
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("id", id);

    return successResponse("Version deleted successfully", "Deleted", 200, resp);
  }
}
