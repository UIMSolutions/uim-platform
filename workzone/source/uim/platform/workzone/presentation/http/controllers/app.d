module uim.platform.workzone.presentation.http.controllers.app;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class AppController : ManageHttpController {
  private ManageAppsUseCase useCase;

  this(ManageAppsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    router.get("/api/v1/apps", &handleList);
    router.get("/api/v1/apps/*", &handleGet);
    router.post("/api/v1/apps", &handleCreate);
    router.put("/api/v1/apps/*", &handleUpdate);
    router.delete_("/api/v1/apps/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto data = precheck.data;
    CreateAppRequest r;
    r.tenantId = precheck.tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.launchUrl = data.getString("launchUrl");
    r.icon = data.getString("icon");
    r.vendor = data.getString("vendor");
    r.version_ = data.getString("version");

    auto result = useCase.createApp(r);
    if (!result.success)
      return errorResponse(result.message, 400);

    return successResponse("App created successfully", "Created", 201,
      Json.emptyObject.set("id", result.id));
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto resources = useCase.listApps(precheck.tenantId);
    auto payload = resources.map!(a => a.toJson()).array.toJson;

    return Json.emptyObject
      .set("count", resources.length)
      .set("resources", payload)
      .set("message", "Apps retrieved successfully")
      .set("status", "success")
      .set("statusCode", 200);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto entity = useCase.getApp(precheck.tenantId, AppId(precheck.id));
    if (entity.isNull)
      return errorResponse("App not found", 404);

    return successResponse("App retrieved successfully", "Retrieved", 200, entity.toJson());
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    UpdateAppRequest r;
    r.id = AppId(precheck.id);
    r.tenantId = precheck.tenantId;
    r.name = precheck.data.getString("name");
    r.description = precheck.data.getString("description");
    r.launchUrl = precheck.data.getString("launchUrl");
    r.icon = precheck.data.getString("icon");
    r.status = toAppStatus(precheck.data.getString("status", "active"));

    auto result = useCase.updateApp(r);
    if (!result.success)
      return errorResponse(result.message, 404);

    return successResponse("App updated successfully", "Updated", 200,
      Json.emptyObject.set("id", result.id));
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto result = useCase.deleteApp(precheck.tenantId, AppId(precheck.id));
    if (!result.success)
      return errorResponse(result.message, 404);

    return successResponse("App deleted successfully", "Deleted", 200, Json.emptyObject);
  }
}
