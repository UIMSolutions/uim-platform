module uim.platform.integration_suite.presentation.http.controllers.integration_users;
import uim.platform.integration_suite;

mixin(ShowModule!());

@safe:

class IntegrationUserController : ManageController {
private:
  IntegrationUserRepository _repo;

public:
  this(IntegrationUserRepository repo) { _repo = repo; }

  override void registerRoutes(URLRouter router) {
    router.get("/api/v1/integration/users",   &handleList);
    router.get("/api/v1/integration/users/*", &handleGet);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    writeError(res, 405, "Method not allowed");
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = getTenantId(req.getTenantId);
      auto items = _repo.getAll(tenantId);
      auto arr = Json.emptyArray;
      foreach (u; items) arr ~= u.toJson();
      res.writeJsonBody(arr, 200);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto u = _repo.getById(getTenantId(req.getTenantId), IntegrationUserId(extractIdFromPath(req)));
      if (u.isNull) { writeError(res, 404, "User not found"); return; }
      res.writeJsonBody(u.toJson(), 200);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    writeError(res, 405, "Method not allowed");
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    writeError(res, 405, "Method not allowed");
  }
}
