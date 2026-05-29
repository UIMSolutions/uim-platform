/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.presentation.http.controllers.workspace;

// import uim.platform.ai_launchpad.application.usecases.manage.workspaces;
// import uim.platform.ai_launchpad.application.dto;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

class WorkspaceController : ManageController {
  private ManageWorkspacesUseCase usecase;

  this(ManageWorkspacesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/workspaces", &handleCreate);
    router.get("/api/v1/workspaces", &handleList);
    router.get("/api/v1/workspaces/*", &handleGet);
    router.patch("/api/v1/workspaces/*", &handlePatch);
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

    auto result = usecase.createWorkspace(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Workspace created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto workspaces = usecase.listWorkspaces(tenantId);

    auto list = workspaces.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Workspace list retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = WorkspaceId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid workspace ID", 400);

    auto workspace = usecase.getWorkspace(tenantId, id);
    if (workspace.isNull)
      return errorResponse("Workspace not found", 404);

    auto responseData = workspace.toJson();
    return successResponse("Workspace retrieved successfully", "Retrieved", 200, responseData);
  }

  protected Json patchHandler(HTTPServerRequest req) {
    auto precheck = super.patchHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = WorkspaceId(precheck.id);
    auto data = precheck.data;
    PatchWorkspaceRequest r;
    r.workspaceId = id;
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");

    auto result = usecase.patchWorkspace(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject
      .set("message", "Workspace updated");

    return successResponse("Workspace updated successfully", "Updated", 200, resp);
  }

  protected void handlePatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = patchHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = WorkspaceId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid workspace ID", 400);

    auto result = usecase.deleteWorkspace(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Workspace deleted successfully", "Deleted", 200, responseData);
  }
}
