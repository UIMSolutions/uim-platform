module uim.platform.databricks.presentation.http.controllers.workspaces;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

class WorkspaceController : ManageController {
private:
  ManageWorkspacesUseCase _usecase;

public:
  this(ManageWorkspacesUseCase usecase) { _usecase = usecase; }

  override void registerRoutes(URLRouter router) {
    router.post   ("/api/v1/databricks/workspaces",   &handleCreate);
    router.get    ("/api/v1/databricks/workspaces",   &handleList);
    router.get    ("/api/v1/databricks/workspaces/*", &handleGet);
    router.put    ("/api/v1/databricks/workspaces/*", &handleUpdate);
    router.delete_("/api/v1/databricks/workspaces/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateWorkspaceRequest r;
      r.tenantId      = req.getTenantId;
      r.id            = precheck.id;
      r.name          = data.getString("name");
      r.region        = data.getString("region");
      r.cloudProvider = data.getString("cloudProvider");
      r.storageRoot   = data.getString("storageRoot");
      r.credentialId  = data.getString("credentialId");
      auto tierStr = data.getString("tier");
      if (tierStr.length > 0) {
        import std.conv : to, ConvException;
        try { r.tier = tierStr.to!WorkspaceTier; } catch (ConvException) {}
      }
      auto result = _usecase.create(r);
      if (result.success) res.writeJsonBody(serializeToJson(result.data), 201);
      else writeError(res, 400, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto result = _usecase.list(req.getTenantId);
      res.writeJsonBody(serializeToJson(result.data));
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;
      auto id     = req.requestPath.to!string.split("/")[$-1];
      auto result = _usecase.get(req.getTenantId, id);
      if (result.success) res.writeJsonBody(serializeToJson(result.data));
      else writeError(res, 404, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;
      auto j = req.json;
      UpdateWorkspaceRequest r;
      r.tenantId    = req.getTenantId;
      r.id          = req.requestPath.to!string.split("/")[$-1];
      r.name        = data.getString("name");
      r.storageRoot = data.getString("storageRoot");
      auto tierStr  = data.getString("tier");
      if (tierStr.length > 0) {
        import std.conv : ConvException;
        try { r.tier = tierStr.to!WorkspaceTier; } catch (ConvException) {}
      }
      auto result = _usecase.update(r);
      if (result.success) res.writeJsonBody(serializeToJson(result.data));
      else writeError(res, 404, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;
      auto id     = req.requestPath.to!string.split("/")[$-1];
      auto result = _usecase.remove(req.getTenantId, id);
      if (result.success) res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
      else writeError(res, 404, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }
}
