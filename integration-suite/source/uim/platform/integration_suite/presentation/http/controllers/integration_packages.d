module uim.platform.integration_suite.presentation.http.controllers.integration_packages;
import uim.platform.integration_suite;

mixin(ShowModule!());

@safe:

class IntegrationPackageController : ManageController {
private:
  ManageIntegrationPackagesUseCase _usecase;

public:
  this(ManageIntegrationPackagesUseCase usecase) { _usecase = usecase; }

  override void registerRoutes(URLRouter router) {
    router.post  ("/api/v1/integration/packages",   &handleCreate);
    router.get   ("/api/v1/integration/packages",   &handleList);
    router.get   ("/api/v1/integration/packages/*", &handleGet);
    router.put   ("/api/v1/integration/packages/*", &handleUpdate);
    router.delete_("/api/v1/integration/packages/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreatePackageRequest r;
      r.tenantId    = req.getTenantId;
      r.id          = precheck.id;
      r.name        = data.getString("name");
      r.version_    = data.getString("version");
      r.description = data.getString("description");
      r.vendor      = data.getString("vendor");
      r.category    = data.getString("category");
      r.tags        = getStrings(j, "tags");
      r.metadata    = jsonStrMap(j, "metadata");
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
      auto id     = extractIdFromPath(req);
      auto result = _usecase.getById(req.getTenantId, id);
      if (result.success) res.writeJsonBody(result.data, 200);
      else writeError(res, 404, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      UpdatePackageRequest r;
      r.tenantId    = req.getTenantId;
      r.id          = extractIdFromPath(req);
      r.name        = data.getString("name");
      r.version_    = data.getString("version");
      r.description = data.getString("description");
      r.status      = data.getString("status");
      r.category    = data.getString("category");
      r.tags        = getStrings(j, "tags");
      r.metadata    = jsonStrMap(j, "metadata");
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
}
