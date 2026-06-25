module uim.platform.workzone.presentation.http.controllers.content;

import uim.platform.workzone;

// mixin(ShowModule!());

@safe:
class ContentController : ManageHttpController {
  private ManageContentUseCase useCase;

  this(ManageContentUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    router.get("/api/v1/content", &handleList);
    router.get("/api/v1/content/*", &handleGet);
    router.post("/api/v1/content", &handleCreate);
    router.put("/api/v1/content/*", &handleUpdate);
    router.delete_("/api/v1/content/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto data = precheck.data;
    CreateContentRequest r;
    r.tenantId = precheck.tenantId;
    r.workspaceId = WorkspaceId(data.getString("workspaceId"));
    r.title = data.getString("title");
    r.body_ = data.getString("body");
    r.summary = data.getString("summary");
    r.contentType = toContentType(data.getString("contentType", "document"));
    r.authorId = UserId(data.getString("authorId"));
    r.authorName = data.getString("authorName");
    r.language = data.getString("language", "en");

    auto result = useCase.createContent(r);
    if (!result.success)
      return errorResponse(result.message, 400);

    return successResponse("Content created successfully", "Created", 201,
      Json.emptyObject.set("id", result.id));
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto workspaceIdRaw = req.query.get("workspaceId", "");
    if (workspaceIdRaw.length == 0)
      return errorResponse("workspaceId query parameter is required", 400);

    auto resources = useCase.listByWorkspace(precheck.tenantId, WorkspaceId(workspaceIdRaw));
    auto payload = resources.map!(c => c.toJson()).array.toJson;

    return successResponse("Content retrieved successfully", "Retrieved", 200,
      Json.emptyObject
        .set("count", resources.length)
        .set("resources", payload));

  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto entity = useCase.getContent(precheck.tenantId, ContentId(precheck.id));
    if (entity.isNull)
      return errorResponse("Content not found", 404);

    return successResponse("Content retrieved successfully", "Retrieved", 200, entity.toJson());
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    UpdateContentRequest r;
    r.id = ContentId(precheck.id);
    r.tenantId = precheck.tenantId;
    r.title = precheck.data.getString("title");
    r.body_ = precheck.data.getString("body");
    r.summary = precheck.data.getString("summary");
    r.status = toContentStatus(precheck.data.getString("status", "draft"));
    r.pinned = precheck.data.getLong("pinned", 0) != 0;

    auto result = useCase.updateContent(r);
    if (!result.success)
      return errorResponse(result.message, 404);

    return successResponse("Content updated successfully", "Updated", 200,
      Json.emptyObject.set("id", result.id));
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto result = useCase.deleteContent(precheck.tenantId, ContentId(precheck.id));
    if (!result.success)
      return errorResponse(result.message, 404);

    return successResponse("Content deleted successfully", "Deleted", 200, Json.emptyObject);
  }
}
