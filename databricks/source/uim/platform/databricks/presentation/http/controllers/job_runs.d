module uim.platform.databricks.presentation.http.controllers.job_runs;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

class JobRunController : ManageHttpController {
private:
  ManageJobRunsUseCase _usecase;

public:
  this(ManageJobRunsUseCase usecase) {
    _usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    router.post("/api/v1/databricks/jobruns", &handleCreate);
    router.get("/api/v1/databricks/jobruns", &handleList);
    router.get("/api/v1/databricks/jobruns/*", &handleGet);
    router.put("/api/v1/databricks/jobruns/*", &handleUpdate);
    router.delete_("/api/v1/databricks/jobruns/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateJobRunRequest r;
    r.tenantId = precheck.tenantId;
    r.id = precheck.id;
    r.jobId = data.getString("jobId");
    r.workspaceId = data.getString("workspaceId");
    r.clusterId = data.getString("clusterId");
    r.runType = data.getString("runType");
    auto trigStr = data.getString("triggerType");
    if (trigStr.length > 0) {
      import std.conv : to, ConvException;

      try {
        r.triggerType = trigStr.to!RunTrigger;
      } catch (ConvException) {
      }
    }
    auto result = _usecase.create(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Job run created successfully", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto result = _usecase.list(req.getTenantId);

        auto responseData = Json.emptyObject.set("count", result.data.length).set("resources", serializeToJson(result.data));
        return successResponse("Job runs retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = req.requestPath.to!string.split("/")[$ - 1];
    auto result = _usecase.get(tenantId, id);
      if (result.isNull)
            return errorResponse("Job run not found", 404);

        auto responseData = result.toJson();
        return successResponse("Job run retrieved successfully", "Retrieved", 200, responseData);
}

override protected Json updateHandler(HTTPServerRequest req) {
  auto precheck = super.updateHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;

  auto data = precheck.data;
  UpdateJobRunRequest r;
  r.tenantId = precheck.tenantId;
  r.id = req.requestPath.to!string.split("/")[$ - 1];
  r.stateMessage = data.getString("stateMessage");
  r.resultState = data.getString("resultState");
  auto stateStr = data.getString("state");
  if (stateStr.length > 0) {
    import std.conv : ConvException;

    try {
      r.state = stateStr.to!RunState;
    } catch (ConvException) {
    }
  }
  auto result = _usecase.update(r);
  if (result.hasError)
    return errorResponse(result.message, 400);

  auto responseData = Json.emptyObject.set("id", result.id);
  return successResponse("Job run updated successfully", 200, responseData);
}

override protected Json deleteHandler(HTTPServerRequest req) {
  auto precheck = super.deleteHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;

  auto id = req.requestPath.to!string.split("/")[$ - 1];
  auto result = _usecase.remove(req.getTenantId, id);
  if (result.hasError)
    return errorResponse(result.message, 400);

  auto responseData = Json.emptyObject.set("id", result.id);
  return successResponse("Job run deleted successfully", 200, responseData);
}
