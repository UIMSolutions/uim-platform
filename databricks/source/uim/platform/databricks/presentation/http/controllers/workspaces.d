module uim.platform.databricks.presentation.http.controllers.workspaces;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

class WorkspaceController : ManageHttpController {
private:
  ManageWorkspacesUseCase _usecase;

public:
  this(ManageWorkspacesUseCase usecase) {
    _usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    router.post("/api/v1/databricks/workspaces", &handleCreate);
    router.get("/api/v1/databricks/workspaces", &handleList);
    router.get("/api/v1/databricks/workspaces/*", &handleGet);
    router.put("/api/v1/databricks/workspaces/*", &handleUpdate);
    router.delete_("/api/v1/databricks/workspaces/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateWorkspaceRequest r;
    r.tenantId = tenantId;
    r.id = precheck.id;
    r.name = data.getString("name");
    r.region = data.getString("region");
    r.cloudProvider = data.getString("cloudProvider");
    r.storageRoot = data.getString("storageRoot");
    r.credentialId = data.getString("credentialId");
    auto tierStr = data.getString("tier");
    if (tierStr.length > 0) {
      import std.conv : to, ConvException;

      try {
        r.tier = tierStr.to!WorkspaceTier;
      } catch (ConvException) {
      }
    }
    auto result = _usecase.create(r);
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
    auto items = _usecase.list(tenantId);
    auto list = items.map!(item => item.toJson()).array.toJson;

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

    auto id = WorkspaceId(req.requestPath.to!string.split("/")[$ - 1]);
    auto result = _usecase.get(tenantId, id);
    if (result.isNull)
      return errorResponse("Workspace not found", 404);

    auto responseData = result.toJson();
    return successResponse("Workspace retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    UpdateWorkspaceRequest r;
    r.tenantId = tenantId;
    r.id = WorkspaceId(req.requestPath.to!string.split("/")[$ - 1]);
    r.name = data.getString("name");
    r.storageRoot = data.getString("storageRoot");
    auto tierStr = data.getString("tier");
    if (tierStr.length > 0) {
      import std.conv : ConvException;

      try {
        r.tier = tierStr.to!WorkspaceTier;
      } catch (ConvException) {
      }
    }
    auto result = _usecase.update(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Workspace updated successfully", "Updated", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = WorkspaceId(req.requestPath.to!string.split("/")[$ - 1]);
    auto result = _usecase.remove(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Workspace deleted successfully", "Deleted", 200, responseData);
  }
}
