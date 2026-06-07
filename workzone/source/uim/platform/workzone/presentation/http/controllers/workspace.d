module uim.platform.workzone.presentation.http.controllers.workspace;

import uim.platform.workzone;

// mixin(ShowModule!());

@safe:
class WorkspaceController : ManageHttpController {
  private ManageWorkspacesUseCase useCase;

  this(ManageWorkspacesUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    router.get("/api/v1/workspaces", &handleList);
    router.get("/api/v1/workspaces/*", &handleGet);
    router.post("/api/v1/workspaces", &handleCreate);
    router.put("/api/v1/workspaces/*", &handleUpdate);
    router.delete_("/api/v1/workspaces/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    CreateWorkspaceRequest r;
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.alias_ = data.getString("alias");
    r.type = toWorkspaceType(data.getString("type", "team"));
    r.createdBy = UserId(data.getString("createdBy"));

    auto result = useCase.createWorkspace(r);
    if (!result.success)
      return errorResponse(result.message, 400);

    return successResponse("Workspace created successfully", "Created", 201,
      Json.emptyObject.set("id", result.id));
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto resources = useCase.listWorkspaces(tenantId);
    auto payload = resources.map!(w => w.toJson()).array.toJson;

    return Json.emptyObject
      .set("count", resources.length)
      .set("resources", payload)
      .set("message", "Workspaces retrieved successfully")
      .set("status", "success")
      .set("statusCode", 200);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto entity = useCase.getWorkspace(precheck.tenantId, WorkspaceId(precheck.id));
    if (entity.isNull)
      return errorResponse("Workspace not found", 404);

    return successResponse("Workspace retrieved successfully", "Retrieved", 200, entity.toJson());
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    UpdateWorkspaceRequest r;
    r.id = WorkspaceId(precheck.id);
    r.tenantId = precheck.tenantId;
    r.name = precheck.data.getString("name");
    r.description = precheck.data.getString("description");
    r.imageUrl = precheck.data.getString("imageUrl");

    auto result = useCase.updateWorkspace(r);
    if (!result.success)
      return errorResponse(result.message, 404);

    return successResponse("Workspace updated successfully", "Updated", 200,
      Json.emptyObject.set("id", result.id));
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto result = useCase.deleteWorkspace(precheck.tenantId, WorkspaceId(precheck.id));
    if (!result.success)
      return errorResponse(result.message, 404);

    return successResponse("Workspace deleted successfully", "Deleted", 200, Json.emptyObject);
  }
}
