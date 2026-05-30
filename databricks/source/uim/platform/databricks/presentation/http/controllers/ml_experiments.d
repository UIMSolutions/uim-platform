module uim.platform.databricks.presentation.http.controllers.ml_experiments;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

class MlExperimentController : ManageController {
private:
  ManageMlExperimentsUseCase _usecase;

public:
  this(ManageMlExperimentsUseCase usecase) { _usecase = usecase; }

  override void registerRoutes(URLRouter router) {
    router.post   ("/api/v1/databricks/experiments",   &handleCreate);
    router.get    ("/api/v1/databricks/experiments",   &handleList);
    router.get    ("/api/v1/databricks/experiments/*", &handleGet);
    router.put    ("/api/v1/databricks/experiments/*", &handleUpdate);
    router.delete_("/api/v1/databricks/experiments/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
      CreateMlExperimentRequest r;
      r.tenantId         = req.getTenantId;
      r.id               = precheck.id;
      r.workspaceId      = data.getString("workspaceId");
      r.name             = data.getString("name");
      r.artifactLocation = data.getString("artifactLocation");
      r.ownerId          = data.getString("ownerId");
      r.tags             = data.getString("tags");
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

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      
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
      UpdateMlExperimentRequest r;
      r.tenantId = req.getTenantId;
      r.id       = req.requestPath.to!string.split("/")[$-1];
      r.name     = data.getString("name");
      r.tags     = data.getString("tags");
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
