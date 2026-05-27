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
      auto data = precheck.data;
      CreateTradingPartnerRequest r;
      r.tenantId     = req.getTenantId;
      r.id           = precheck.id;
      r.name         = data.getString("name");
      r.description  = data.getString("description");
      r.partnerType  = data.getString("partnerType");
      r.standard     = data.getString("standard");
      r.systemId     = data.getString("systemId");
      r.contactEmail = data.getString("contactEmail");
      r.contactName  = data.getString("contactName");
      r.country      = data.getString("country");
      r.metadata     = data.jsonStrMap("metadata");
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
      UpdateTradingPartnerRequest r;
      r.tenantId     = req.getTenantId;
      r.id           = extractIdFromPath(req);
      r.name         = data.getString("name");
      r.contactEmail = data.getString("contactEmail");
      r.contactName  = data.getString("contactName");
      r.standard     = data.getString("standard");
      r.active       = data.getBoolean("active");
      r.metadata     = data.jsonStrMap("metadata");
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
