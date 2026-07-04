module uim.platform.integration_suite.presentation.http.controllers.trading_partners;
import uim.platform.integration_suite;

mixin(ShowModule!());

@safe:

class TradingPartnerController : ManageHttpController {
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

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
      CreateTradingPartnerRequest r;
      r.tenantId     = tenantId;
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
      if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Trading partner created successfully", "Created", 201, responseData);
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
      if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Trading partner retrieved successfully", "OK", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      UpdateTradingPartnerRequest r;
      r.tenantId     = tenantId;
      r.id           = precheck.id;
      r.name         = data.getString("name");
      r.contactEmail = data.getString("contactEmail");
      r.contactName  = data.getString("contactName");
      r.standard     = data.getString("standard");
      r.active       = data.getBoolean("active");
      r.metadata     = data.jsonStrMap("metadata");
      auto result = _usecase.update(r);
      if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Trading partner updated successfully", "Updated", 200, responseData);
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
        return successResponse("Trading partner deleted successfully", "Deleted", 200, responseData);
  }
}
