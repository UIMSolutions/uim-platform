module uim.platform.integration_suite.presentation.http.controllers.api_proxies;
import uim.platform.integration_suite;

mixin(ShowModule!());

@safe:

class ApiProxyController : ManageController {
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
      r.tenantId       = req.getTenantId;
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
      if (result.success) res.writeJsonBody(result.data, 201);
      else writeError(res, 400, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto result = _usecase.getAll(req.getTenantId);
      if (result.success) res.writeJsonBody(result.data, 200);
      else writeError(res, 500, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto result = _usecase.getById(req.getTenantId, extractIdFromPath(req));
      if (result.success) res.writeJsonBody(result.data, 200);
      else writeError(res, 404, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto data = precheck.data;
      UpdateApiProxyRequest r;
      r.tenantId       = req.getTenantId;
      r.id             = extractIdFromPath(req);
      r.name           = data.getString("name");
      r.description    = data.getString("description");
      r.status         = data.getString("status");
      r.targetEndpoint = data.getString("targetEndpoint");
      r.policies       = data.getStrings("policies");
      r.tags           = data.getStrings("tags");
      r.metadata       = data.jsonStrMap("metadata");
      auto result = _usecase.update(r);
      if (result.success) res.writeJsonBody(result.data, 200);
      else writeError(res, 404, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto result = _usecase.remove(req.getTenantId, extractIdFromPath(req));
      if (result.success) res.writeJsonBody(Json.emptyObject.set("message", "Deleted"), 200);
      else writeError(res, 404, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  protected void handlePublish(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto result = _usecase.publish(req.getTenantId, extractIdFromPath(req));
      if (result.success) res.writeJsonBody(result.data, 200);
      else writeError(res, 404, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }
}
