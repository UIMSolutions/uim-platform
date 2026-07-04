module uim.platform.databricks.presentation.http.controllers.jobs;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

class JobController : ManageHttpController {
private:
  ManageJobsUseCase _usecase;

public:
  this(ManageJobsUseCase usecase) {
    _usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    router.post("/api/v1/databricks/jobs", &handleCreate);
    router.get("/api/v1/databricks/jobs", &handleList);
    router.get("/api/v1/databricks/jobs/*", &handleGet);
    router.put("/api/v1/databricks/jobs/*", &handleUpdate);
    router.delete_("/api/v1/databricks/jobs/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateJobRequest r;
    r.tenantId = tenantId;
    r.id = precheck.id;
    r.workspaceId = data.getString("workspaceId");
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.creatorId = data.getString("creatorId");
    r.schedule = data.getString("schedule");
    r.taskType = data.getString("taskType");
    r.taskSettings = data.getString("taskSettings");
    r.clusterId = data.getString("clusterId");
    r.maxRetries = j.getInt("maxRetries");
    r.minRetryIntervalMs = j.getInt("minRetryIntervalMs");
    r.maxConcurrentRuns = j.getInt("maxConcurrentRuns");
    auto result = _usecase.create(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Job created successfully", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto result = _usecase.list(req.getTenantId);
    
    auto responseData = Json.emptyObject.set("count", result.data.length).set("resources", serializeToJson(result.data));
    return successResponse("Jobs retrieved successfully", "Retrieved", 200, responseData);
}

override protected Json getHandler(HTTPServerRequest req) {
  auto precheck = super.getHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;

  auto id = req.requestPath.to!string.split("/")[$ - 1];
  auto result = _usecase.get(tenantId, id);
  if (result.isNull)
    return errorResponse("Job not found", 404);

  auto responseData = result.toJson();
  return successResponse("Job retrieved successfully", "Retrieved", 200, responseData);
}

override protected Json updateHandler(HTTPServerRequest req) {
  auto precheck = super.updateHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;

  auto data = precheck.data;
  UpdateJobRequest r;
  r.tenantId = tenantId;
  r.id = req.requestPath.to!string.split("/")[$ - 1];
  r.name = data.getString("name");
  r.description = data.getString("description");
  r.schedule = data.getString("schedule");
  r.taskSettings = data.getString("taskSettings");
  r.maxRetries = j.getInt("maxRetries");
  r.maxConcurrentRuns = j.getInt("maxConcurrentRuns");
  auto result = _usecase.update(r);
  if (result.hasError)
    return errorResponse(result.message, 400);

  auto responseData = Json.emptyObject.set("id", result.id);
  return successResponse("Job updated successfully", "Updated", 200, responseData);
}

override protected Json deleteHandler(HTTPServerRequest req) {
  auto precheck = super.deleteHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;

  auto id = req.requestPath.to!string.split("/")[$ - 1];
  auto result = _usecase.remove(tenantId, id);
  if (result.hasError)
    return errorResponse(result.message, 400);

  auto responseData = Json.emptyObject.set("id", result.id);
  return successResponse("Job deleted successfully", 200, responseData);
}
}
