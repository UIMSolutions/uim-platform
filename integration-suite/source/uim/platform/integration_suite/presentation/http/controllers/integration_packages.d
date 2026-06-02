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

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
      CreatePackageRequest r;
      r.tenantId    = req.getTenantId;
      r.id          = precheck.id;
      r.name        = data.getString("name");
      r.version_    = data.getString("version");
      r.description = data.getString("description");
      r.vendor      = data.getString("vendor");
      r.category    = data.getString("category");
      r.tags        = data.getStrings("tags");
      r.metadata    = data.jsonStrMap("metadata");
      auto result = _usecase.create(r);
      if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Integration package created successfully", "Created", 201, responseData);
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
      auto id     = precheck.id;
      auto result = _usecase.getById(req.getTenantId, id);
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
      UpdatePackageRequest r;
      r.tenantId    = req.getTenantId;
      r.id          = precheck.id;
      r.name        = data.getString("name");
      r.version_    = data.getString("version");
      r.description = data.getString("description");
      r.status      = data.getString("status");
      r.category    = data.getString("category");
      r.tags        = data.getStrings("tags");
      r.metadata    = data.jsonStrMap("metadata");
      auto result = _usecase.update(r);
      if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Integration package updated successfully", "Updated", 200, responseData);
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
        return successResponse("Integration package deleted successfully", "Deleted", 200, responseData);
  }
}
