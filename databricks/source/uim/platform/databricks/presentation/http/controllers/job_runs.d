module uim.platform.databricks.presentation.http.controllers.job_runs;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

class JobRunController : ManageController {
private:
  ManageJobRunsUseCase _usecase;

public:
  this(ManageJobRunsUseCase usecase) { _usecase = usecase; }

  override void registerRoutes(URLRouter router) {
    router.post   ("/api/v1/databricks/jobruns",   &handleCreate);
    router.get    ("/api/v1/databricks/jobruns",   &handleList);
    router.get    ("/api/v1/databricks/jobruns/*", &handleGet);
    router.put    ("/api/v1/databricks/jobruns/*", &handleUpdate);
    router.delete_("/api/v1/databricks/jobruns/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateJobRunRequest r;
      r.tenantId    = req.getTenantId;
      r.id          = precheck.id;
      r.jobId       = j.getString("jobId");
      r.workspaceId = j.getString("workspaceId");
      r.clusterId   = j.getString("clusterId");
      r.runType     = j.getString("runType");
      auto trigStr  = j.getString("triggerType");
      if (trigStr.length > 0) {
        import std.conv : to, ConvException;
        try { r.triggerType = trigStr.to!RunTrigger; } catch (ConvException) {}
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
      UpdateJobRunRequest r;
      r.tenantId    = req.getTenantId;
      r.id          = req.requestPath.to!string.split("/")[$-1];
      r.stateMessage= j.getString("stateMessage");
      r.resultState = j.getString("resultState");
      auto stateStr = j.getString("state");
      if (stateStr.length > 0) {
        import std.conv : ConvException;
        try { r.state = stateStr.to!RunState; } catch (ConvException) {}
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
