module uim.platform.workzone.presentation.http.controllers.widget;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class WidgetController : ManageController {
  private ManageWidgetsUseCase useCase;

  this(ManageWidgetsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    router.get("/api/v1/widgets", &handleList);
    router.get("/api/v1/widgets/*", &handleGet);
    router.post("/api/v1/widgets", &handleCreate);
    router.put("/api/v1/widgets/*", &handleUpdate);
    router.delete_("/api/v1/widgets/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto data = precheck.data;
    CreateWidgetRequest r;
    r.tenantId = precheck.tenantId;
    r.pageId = WorkpageId(data.getString("pageId"));
    r.title = data.getString("title");
    r.cardId = CardId(data.getString("cardId"));
    r.appId = AppId(data.getString("appId"));
    r.size = toWidgetSize(data.getString("size", "medium"));
    r.row = cast(int) data.getLong("row", 0);
    r.col = cast(int) data.getLong("col", 0);
    r.sortOrder = cast(int) data.getLong("sortOrder", 0);

    auto result = useCase.createWidget(r);
    if (!result.success)
      return errorResponse(result.message, 400);

    return successResponse("Widget created successfully", "Created", 201,
      Json.emptyObject.set("id", result.id));
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto pageIdRaw = req.query.get("pageId", "");
    if (pageIdRaw.length == 0)
      return errorResponse("pageId query parameter is required", 400);

    auto resources = useCase.listWidgets(precheck.tenantId, WorkpageId(pageIdRaw));
    auto payload = resources.map!(w => w.toJson()).array.toJson;

    return Json.emptyObject
      .set("count", resources.length)
      .set("resources", payload)
      .set("message", "Widgets retrieved successfully")
      .set("status", "success")
      .set("statusCode", 200);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto entity = useCase.getWidget(precheck.tenantId, WidgetId(precheck.id));
    if (entity.isNull)
      return errorResponse("Widget not found", 404);

    return successResponse("Widget retrieved successfully", "Retrieved", 200, entity.toJson());
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    UpdateWidgetRequest r;
    r.id = WidgetId(precheck.id);
    r.tenantId = precheck.tenantId;
    r.title = precheck.data.getString("title");
    r.size = toWidgetSize(precheck.data.getString("size", "medium"));
    r.row = cast(int) precheck.data.getLong("row", 0);
    r.col = cast(int) precheck.data.getLong("col", 0);
    r.sortOrder = cast(int) precheck.data.getLong("sortOrder", 0);
    r.visible = precheck.data.getLong("visible", 1) != 0;

    auto result = useCase.updateWidget(r);
    if (!result.success)
      return errorResponse(result.message, 404);

    return successResponse("Widget updated successfully", "Updated", 200,
      Json.emptyObject.set("id", result.id));
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto result = useCase.deleteWidget(precheck.tenantId, WidgetId(precheck.id));
    if (!result.success)
      return errorResponse(result.message, 404);

    return successResponse("Widget deleted successfully", "Deleted", 200, Json.emptyObject);
  }
}
