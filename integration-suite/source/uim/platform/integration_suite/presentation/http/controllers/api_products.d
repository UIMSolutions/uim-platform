module uim.platform.integration_suite.presentation.http.controllers.api_products;
import uim.platform.integration_suite;

// mixin(ShowModule!());

@safe:

class ApiProductController : ManageHttpController {
private:
  ManageApiProductsUseCase _usecase;

public:
  this(ManageApiProductsUseCase usecase) {
    _usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    router.post("/api/v1/apimanagement/products", &handleCreate);
    router.get("/api/v1/apimanagement/products", &handleList);
    router.get("/api/v1/apimanagement/products/*", &handleGet);
    router.put("/api/v1/apimanagement/products/*", &handleUpdate);
    router.delete_("/api/v1/apimanagement/products/*", &handleDelete);
    router.post("/api/v1/apimanagement/products/publish/*", &handlePublish);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateApiProductRequest r;
    r.tenantId = tenantId;
    r.id = precheck.id;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.apiProxyIds = data.getStrings("apiProxyIds");
    r.scopes = data.getStrings("scopes");
    r.environments = data.getStrings("environments");
    r.metadata = data.jsonStrMap("metadata");
    auto result = _usecase.create(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("API product created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto result = _usecase.getAll(tenantId);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto arr = Json.emptyArray;
    foreach (p; result.data)
      arr ~= p.toJson();

    return successResponse("API products retrieved successfully", "OK", 200, arr);

  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto result = _usecase.getById(tenantId, precheck.id);
    if (result.hasError)
      return errorResponse(result.message, 404);

    auto responseData = result.data.toJson();
    return successResponse("API product retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    UpdateApiProductRequest r;
    r.tenantId = tenantId;
    r.id = precheck.id;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.apiProxyIds = data.getStrings("apiProxyIds");
    r.status = data.getString("status");
    r.isPublic = data.getBoolean("isPublic");
    r.metadata = data.jsonStrMap("metadata");
    auto result = _usecase.update(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("API product updated successfully", "Updated", 200, responseData);
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
    return successResponse("API product deleted successfully", "Deleted", 200, responseData);
  }

  protected Json publishHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto result = _usecase.publish(tenantId, precheck.id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", precheck.id);
    return successResponse("API product published successfully", "Published", 200, resp);
  }

  protected void handlePublish(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = publishHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
