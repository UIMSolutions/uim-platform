module uim.platform.databricks.presentation.http.controllers.workspaces;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

class WorkspaceController : ManageHttpController {
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

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
      CreateWorkspaceRequest r;
      r.tenantId      = tenantId;
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

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
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
      auto result = _usecase.get(tenantId, id);
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
      UpdateWorkspaceRequest r;
      r.tenantId    = tenantId;
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
