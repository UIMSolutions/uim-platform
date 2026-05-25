module uim.platform.databricks.presentation.http.controllers.ml_models;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

class MlModelController : ManageController {
private:
  ManageMlModelsUseCase _usecase;

public:
  this(ManageMlModelsUseCase usecase) { _usecase = usecase; }

  override void registerRoutes(URLRouter router) {
    router.post   ("/api/v1/databricks/models",   &handleCreate);
    router.get    ("/api/v1/databricks/models",   &handleList);
    router.get    ("/api/v1/databricks/models/*", &handleGet);
    router.put    ("/api/v1/databricks/models/*", &handleUpdate);
    router.delete_("/api/v1/databricks/models/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateMlModelRequest r;
      r.tenantId    = req.getTenantId;
      r.id          = j.getString("id");
      r.workspaceId = j.getString("workspaceId");
      r.name        = j.getString("name");
      r.description = j.getString("description");
      r.ownerId     = j.getString("ownerId");
      r.source      = j.getString("source");
      r.tags        = j.getString("tags");
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
      UpdateMlModelRequest r;
      r.tenantId    = req.getTenantId;
      r.id          = req.requestPath.to!string.split("/")[$-1];
      r.description = j.getString("description");
      r.tags        = j.getString("tags");
      auto stageStr = j.getString("latestStage");
      if (stageStr.length > 0) {
        import std.conv : ConvException;
        try { r.latestStage = stageStr.to!ModelStage; } catch (ConvException) {}
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
