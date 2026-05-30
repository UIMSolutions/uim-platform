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

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
      CreateFlowRequest r;
      r.tenantId            = req.getTenantId;
      r.id                  = precheck.id;
      r.packageId           = data.getString("packageId");
      r.name                = data.getString("name");
      r.description         = data.getString("description");
      r.version_            = data.getString("version");
      r.direction           = data.getString("direction");
      r.senderAdapterType   = data.getString("senderAdapterType");
      r.receiverAdapterType = data.getString("receiverAdapterType");
      r.senderEndpoint      = data.getString("senderEndpoint");
      r.receiverEndpoint    = data.getString("receiverEndpoint");
      r.steps               = data.getStrings("steps");
      r.metadata            = data.jsonStrMap("metadata");
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
      UpdateFlowRequest r;
      r.tenantId    = req.getTenantId;
      r.id          = extractIdFromPath(req);
      r.name        = data.getString("name");
      r.description = data.getString("description");
      r.version_    = data.getString("version");
      r.status      = data.getString("status");
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
