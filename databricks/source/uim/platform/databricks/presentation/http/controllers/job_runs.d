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

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
      CreateJobRunRequest r;
      r.tenantId    = req.getTenantId;
      r.id          = precheck.id;
      r.jobId       = data.getString("jobId");
      r.workspaceId = data.getString("workspaceId");
      r.clusterId   = data.getString("clusterId");
      r.runType     = data.getString("runType");
      auto trigStr  = data.getString("triggerType");
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
      
      auto id     = req.requestPath.to!string.split("/")[$-1];
      auto result = _usecase.get(req.getTenantId, id);
      if (result.success) res.writeJsonBody(serializeToJson(result.data));
      else writeError(res, 404, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      
      auto data = precheck.data;
      UpdateJobRunRequest r;
      r.tenantId    = req.getTenantId;
      r.id          = req.requestPath.to!string.split("/")[$-1];
      r.stateMessage= data.getString("stateMessage");
      r.resultState = data.getString("resultState");
      auto stateStr = data.getString("state");
      if (stateStr.length > 0) {
        import std.conv : ConvException;
        try { r.state = stateStr.to!RunState; } catch (ConvException) {}
      }
      auto result = _usecase.update(r);
      if (result.success) res.writeJsonBody(serializeToJson(result.data));
      else writeError(res, 404, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      
      auto id     = req.requestPath.to!string.split("/")[$-1];
      auto result = _usecase.remove(req.getTenantId, id);
      if (result.success) res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
      else writeError(res, 404, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }
}
