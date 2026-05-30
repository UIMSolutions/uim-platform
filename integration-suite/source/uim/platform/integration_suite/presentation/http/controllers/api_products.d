module uim.platform.integration_suite.presentation.http.controllers.api_products;
import uim.platform.integration_suite;

mixin(ShowModule!());

@safe:

class ApiProductController : ManageController {
private:
  ManageApiProductsUseCase _usecase;

public:
  this(ManageApiProductsUseCase usecase) { _usecase = usecase; }

  override void registerRoutes(URLRouter router) {
    router.post   ("/api/v1/apimanagement/products",           &handleCreate);
    router.get    ("/api/v1/apimanagement/products",           &handleList);
    router.get    ("/api/v1/apimanagement/products/*",         &handleGet);
    router.put    ("/api/v1/apimanagement/products/*",         &handleUpdate);
    router.delete_("/api/v1/apimanagement/products/*",         &handleDelete);
    router.post   ("/api/v1/apimanagement/products/publish/*", &handlePublish);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
      CreateApiProductRequest r;
      r.tenantId    = req.getTenantId;
      r.id          = precheck.id;
      r.name        = data.getString("name");
      r.description = data.getString("description");
      r.apiProxyIds = data.getStrings("apiProxyIds");
      r.scopes      = data.getStrings("scopes");
      r.environments= data.getStrings("environments");
      r.metadata    = data.jsonStrMap("metadata");
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
      UpdateApiProductRequest r;
      r.tenantId    = req.getTenantId;
      r.id          = extractIdFromPath(req);
      r.name        = data.getString("name");
      r.description = data.getString("description");
      r.apiProxyIds = data.getStrings("apiProxyIds");
      r.status      = data.getString("status");
      r.isPublic    = data.getBoolean("isPublic");
      r.metadata    = data.jsonStrMap("metadata");
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
