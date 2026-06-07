module uim.platform.workzone.presentation.http.controllers.feed;

import uim.platform.workzone;

// mixin(ShowModule!());

@safe:
class FeedController : ManageHttpController {
  private ManageFeedsUseCase useCase;

  this(ManageFeedsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    router.get("/api/v1/feeds", &handleList);
    router.get("/api/v1/feeds/*", &handleGet);
    router.post("/api/v1/feeds", &handleCreate);
    router.delete_("/api/v1/feeds/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto data = precheck.data;
    CreateFeedEntryRequest r;
    r.tenantId = precheck.tenantId;
    r.workspaceId = WorkspaceId(data.getString("workspaceId"));
    r.actorId = UserId(data.getString("actorId"));
    r.actorName = data.getString("actorName");
    r.action = data.getString("action");
    r.objectType = data.getString("objectType");
    r.objectId = data.getString("objectId");
    r.objectTitle = data.getString("objectTitle");
    r.message = data.getString("message");

    auto result = useCase.createFeedEntry(r);
    if (!result.success)
      return errorResponse(result.message, 400);

    return successResponse("Feed entry created successfully", "Created", 201,
      Json.emptyObject.set("id", result.id));
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto workspaceIdRaw = req.query.get("workspaceId", "");
    if (workspaceIdRaw.length == 0)
      return errorResponse("workspaceId query parameter is required", 400);

    auto resources = useCase.listFeedEntries(precheck.tenantId, WorkspaceId(workspaceIdRaw));
    auto payload = resources.map!(f => f.toJson()).array.toJson;

    return Json.emptyObject
      .set("count", resources.length)
      .set("resources", payload)
      .set("message", "Feed entries retrieved successfully")
      .set("status", "success")
      .set("statusCode", 200);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto entity = useCase.getFeedEntry(precheck.tenantId, FeedEntryId(precheck.id));
    if (entity.isNull)
      return errorResponse("Feed entry not found", 404);

    return successResponse("Feed entry retrieved successfully", "Retrieved", 200, entity.toJson());
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    return errorResponse("Feed entries are immutable", 405);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto result = useCase.deleteFeedEntry(precheck.tenantId, FeedEntryId(precheck.id));
    if (!result.success)
      return errorResponse(result.message, 404);

    return successResponse("Feed entry deleted successfully", "Deleted", 200, Json.emptyObject);
  }
}
