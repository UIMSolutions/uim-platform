module uim.platform.integration_suite.presentation.http.controllers.integration_flows;
import uim.platform.integration_suite;

mixin(ShowModule!());

@safe:

class IntegrationFlowController : ManageController {
private:
  ManageIntegrationFlowsUseCase _usecase;

public:
  this(ManageIntegrationFlowsUseCase usecase) { _usecase = usecase; }

  override void registerRoutes(URLRouter router) {
    router.post   ("/api/v1/integration/flows",          &handleCreate);
    router.get    ("/api/v1/integration/flows",          &handleList);
    router.get    ("/api/v1/integration/flows/*",        &handleGet);
    router.put    ("/api/v1/integration/flows/*",        &handleUpdate);
    router.delete_("/api/v1/integration/flows/*",        &handleDelete);
    router.post   ("/api/v1/integration/flows/deploy/*", &handleDeploy);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateFlowRequest r;
      r.tenantId            = req.getTenantId;
      r.id                  = j.getString("id");
      r.packageId           = j.getString("packageId");
      r.name                = j.getString("name");
      r.description         = j.getString("description");
      r.version_            = j.getString("version");
      r.direction           = j.getString("direction");
      r.senderAdapterType   = j.getString("senderAdapterType");
      r.receiverAdapterType = j.getString("receiverAdapterType");
      r.senderEndpoint      = j.getString("senderEndpoint");
      r.receiverEndpoint    = j.getString("receiverEndpoint");
      r.steps               = getStrings(j, "steps");
      r.metadata            = jsonStrMap(j, "metadata");
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
      auto j = req.json;
      UpdateFlowRequest r;
      r.tenantId    = req.getTenantId;
      r.id          = extractIdFromPath(req);
      r.name        = j.getString("name");
      r.description = j.getString("description");
      r.version_    = j.getString("version");
      r.status      = j.getString("status");
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

  protected void handleDeploy(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      DeployFlowRequest r;
      r.tenantId   = req.getTenantId;
      r.id         = extractIdFromPath(req);
      r.deployedBy = req.headers.get("X-User-Id", "system");
      auto result = _usecase.deploy(r);
      if (result.success) res.writeJsonBody(result.data, 200);
      else writeError(res, 404, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }
}
