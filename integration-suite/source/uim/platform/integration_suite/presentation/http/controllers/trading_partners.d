module uim.platform.integration_suite.presentation.http.controllers.trading_partners;
import uim.platform.integration_suite;

mixin(ShowModule!());

@safe:

class TradingPartnerController : ManageController {
private:
  ManageTradingPartnersUseCase _usecase;

public:
  this(ManageTradingPartnersUseCase usecase) { _usecase = usecase; }

  override void registerRoutes(URLRouter router) {
    router.post   ("/api/v1/b2b/partners",   &handleCreate);
    router.get    ("/api/v1/b2b/partners",   &handleList);
    router.get    ("/api/v1/b2b/partners/*", &handleGet);
    router.put    ("/api/v1/b2b/partners/*", &handleUpdate);
    router.delete_("/api/v1/b2b/partners/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateTradingPartnerRequest r;
      r.tenantId     = req.getTenantId;
      r.id           = precheck.id;
      r.name         = j.getString("name");
      r.description  = j.getString("description");
      r.partnerType  = j.getString("partnerType");
      r.standard     = j.getString("standard");
      r.systemId     = j.getString("systemId");
      r.contactEmail = j.getString("contactEmail");
      r.contactName  = j.getString("contactName");
      r.country      = j.getString("country");
      r.metadata     = jsonStrMap(j, "metadata");
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
      UpdateTradingPartnerRequest r;
      r.tenantId     = req.getTenantId;
      r.id           = extractIdFromPath(req);
      r.name         = j.getString("name");
      r.contactEmail = j.getString("contactEmail");
      r.contactName  = j.getString("contactName");
      r.standard     = j.getString("standard");
      r.active       = j.getBool("active");
      r.metadata     = jsonStrMap(j, "metadata");
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
