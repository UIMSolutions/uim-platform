module uim.platform.databricks.presentation.http.controllers.jobs;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

class JobController : ManageController {
private:
  ManageJobsUseCase _usecase;

public:
  this(ManageJobsUseCase usecase) { _usecase = usecase; }

  override void registerRoutes(URLRouter router) {
    router.post   ("/api/v1/databricks/jobs",   &handleCreate);
    router.get    ("/api/v1/databricks/jobs",   &handleList);
    router.get    ("/api/v1/databricks/jobs/*", &handleGet);
    router.put    ("/api/v1/databricks/jobs/*", &handleUpdate);
    router.delete_("/api/v1/databricks/jobs/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateJobRequest r;
      r.tenantId           = req.getTenantId;
      r.id                 = precheck.id;
      r.workspaceId        = data.getString("workspaceId");
      r.name               = data.getString("name");
      r.description        = data.getString("description");
      r.creatorId          = data.getString("creatorId");
      r.schedule           = data.getString("schedule");
      r.taskType           = data.getString("taskType");
      r.taskSettings       = data.getString("taskSettings");
      r.clusterId          = data.getString("clusterId");
      r.maxRetries         = j.getInt("maxRetries");
      r.minRetryIntervalMs = j.getInt("minRetryIntervalMs");
      r.maxConcurrentRuns  = j.getInt("maxConcurrentRuns");
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
      UpdateJobRequest r;
      r.tenantId           = req.getTenantId;
      r.id                 = req.requestPath.to!string.split("/")[$-1];
      r.name               = data.getString("name");
      r.description        = data.getString("description");
      r.schedule           = data.getString("schedule");
      r.taskSettings       = data.getString("taskSettings");
      r.maxRetries         = j.getInt("maxRetries");
      r.maxConcurrentRuns  = j.getInt("maxConcurrentRuns");
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
