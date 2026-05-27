module uim.platform.databricks.presentation.http.controllers.notebooks;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

class NotebookController : ManageController {
private:
  ManageNotebooksUseCase _usecase;

public:
  this(ManageNotebooksUseCase usecase) { _usecase = usecase; }

  override void registerRoutes(URLRouter router) {
    router.post   ("/api/v1/databricks/notebooks",   &handleCreate);
    router.get    ("/api/v1/databricks/notebooks",   &handleList);
    router.get    ("/api/v1/databricks/notebooks/*", &handleGet);
    router.put    ("/api/v1/databricks/notebooks/*", &handleUpdate);
    router.delete_("/api/v1/databricks/notebooks/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateNotebookRequest r;
      r.tenantId    = req.getTenantId;
      r.id          = precheck.id;
      r.workspaceId = data.getString("workspaceId");
      r.path        = data.getString("path");
      r.name        = data.getString("name");
      r.content     = data.getString("content");
      r.format      = data.getString("format");
      r.ownerId     = data.getString("ownerId");
      auto langStr  = data.getString("language");
      if (langStr.length > 0) {
        import std.conv : to, ConvException;
        try { r.language = langStr.to!NotebookLanguage; } catch (ConvException) {}
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
      UpdateNotebookRequest r;
      r.tenantId = req.getTenantId;
      r.id       = req.requestPath.to!string.split("/")[$-1];
      r.name     = data.getString("name");
      r.content  = data.getString("content");
      r.format   = data.getString("format");
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
