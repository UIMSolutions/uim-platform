module uim.platform.workzone.presentation.http.controllers.workpage;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class WorkpageController : ManageController {
  private ManageWorkpagesUseCase useCase;

  this(ManageWorkpagesUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    router.get("/api/v1/workpages", &handleList);
    router.get("/api/v1/workpages/*", &handleGet);
    router.post("/api/v1/workpages", &handleCreate);
    router.put("/api/v1/workpages/*", &handleUpdate);
    router.delete_("/api/v1/workpages/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto data = precheck.data;
    CreateWorkpageRequest r;
    r.tenantId = precheck.tenantId;
    r.workspaceId = WorkspaceId(data.getString("workspaceId"));
    r.title = data.getString("title");
    r.description = data.getString("description");
    r.sortOrder = cast(int) data.getLong("sortOrder", 0);
    r.isDefault = data.getLong("isDefault", 0) != 0;

    auto result = useCase.createWorkpage(r);
    if (!result.success)
      return errorResponse(result.message, 400);

    return successResponse("Workpage created successfully", "Created", 201,
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
    auto payload = resources.map!(p => p.toJson()).array.toJson;

    return Json.emptyObject
      .set("count", resources.length)
      .set("resources", payload)
      .set("message", "Workpages retrieved successfully")
      .set("status", "success")
      .set("statusCode", 200);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto entity = useCase.getWorkpage(precheck.tenantId, WorkpageId(precheck.id));
    if (entity.isNull)
      return errorResponse("Workpage not found", 404);

    return successResponse("Workpage retrieved successfully", "Retrieved", 200, entity.toJson());
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    UpdateWorkpageRequest r;
    r.id = WorkpageId(precheck.id);
    r.tenantId = precheck.tenantId;
    r.title = precheck.data.getString("title");
    r.description = precheck.data.getString("description");
    r.sortOrder = cast(int) precheck.data.getLong("sortOrder", 0);
    r.visible = precheck.data.getLong("visible", 1) != 0;

    auto result = useCase.updateWorkpage(r);
    if (!result.success)
      return errorResponse(result.message, 404);

    return successResponse("Workpage updated successfully", "Updated", 200,
      Json.emptyObject.set("id", result.id));
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto result = useCase.deleteWorkpage(precheck.tenantId, WorkpageId(precheck.id));
    if (!result.success)
      return errorResponse(result.message, 404);

    return successResponse("Workpage deleted successfully", "Deleted", 200, Json.emptyObject);
  }
}
