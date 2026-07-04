module uim.platform.integration_suite.presentation.http.controllers.api_proxies;
import uim.platform.integration_suite;

mixin(ShowModule!());

@safe:

class ApiProxyController : ManageHttpController {
private:
  ManageApiProxiesUseCase _usecase;

public:
  this(ManageApiProxiesUseCase usecase) { _usecase = usecase; }

  override void registerRoutes(URLRouter router) {
    router.post   ("/api/v1/apimanagement/proxies",          &handleCreate);
    router.get    ("/api/v1/apimanagement/proxies",          &handleList);
    router.get    ("/api/v1/apimanagement/proxies/*",        &handleGet);
    router.put    ("/api/v1/apimanagement/proxies/*",        &handleUpdate);
    router.delete_("/api/v1/apimanagement/proxies/*",        &handleDelete);
    router.post   ("/api/v1/apimanagement/proxies/publish/*", &handlePublish);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
      CreateApiProxyRequest r;
      r.tenantId       = tenantId;
      r.id             = precheck.id;
      r.name           = data.getString("name");
      r.description    = data.getString("description");
      r.version_       = data.getString("version");
      r.targetEndpoint = data.getString("targetEndpoint");
      r.basePath       = data.getString("basePath");
      r.policies       = data.getStrings("policies");
      r.tags           = data.getStrings("tags");
      r.metadata       = data.jsonStrMap("metadata");
      auto result = _usecase.create(r);
      if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("API proxy created successfully", 201, responseData);
 }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto result = _usecase.getAll(req.getTenantId);
      if (result.success) res.writeJsonBody(result.data, 200);
      else writeError(res, 500, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto result = _usecase.getById(req.getTenantId, precheck.id);
      if (result.success) res.writeJsonBody(result.data, 200);
      else writeError(res, 404, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      UpdateApiProxyRequest r;
      r.tenantId       = tenantId;
      r.id             = precheck.id;
      r.name           = data.getString("name");
      r.description    = data.getString("description");
      r.status         = data.getString("status");
      r.targetEndpoint = data.getString("targetEndpoint");
      r.policies       = data.getStrings("policies");
      r.tags           = data.getStrings("tags");
      r.metadata       = data.jsonStrMap("metadata");
      auto result = _usecase.update(r);
      if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("API proxy updated successfully", 200, responseData);
  }


  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto result = _usecase.remove(req.getTenantId, precheck.id);
      if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("API proxy deleted successfully", 200, responseData);
  }


  protected void handlePublish(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto result = _usecase.publish(req.getTenantId, precheck.id);
      if (result.success) res.writeJsonBody(result.data, 200);
      else writeError(res, 404, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }
}
