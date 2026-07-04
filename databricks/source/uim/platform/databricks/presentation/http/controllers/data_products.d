module uim.platform.databricks.presentation.http.controllers.data_products;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

class DataProductController : ManageHttpController {
private:
  ManageDataProductsUseCase _usecase;

public:
  this(ManageDataProductsUseCase usecase) {
    _usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    router.post("/api/v1/databricks/dataproducts", &handleCreate);
    router.get("/api/v1/databricks/dataproducts", &handleList);
    router.get("/api/v1/databricks/dataproducts/*", &handleGet);
    router.put("/api/v1/databricks/dataproducts/*", &handleUpdate);
    router.delete_("/api/v1/databricks/dataproducts/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateDataProductRequest r;
    r.tenantId = tenantId;
    r.id = DataProductId(precheck.id); // allow client to specify ID or generate new one if not provided
    r.workspaceId = data.getString("workspaceId");
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.provider = data.getString("provider");
    r.version_ = data.getString("version");
    r.targetCatalog = data.getString("targetCatalog");
    r.targetSchema = data.getString("targetSchema");
    r.sourceSystemId = data.getString("sourceSystemId");
    r.tags = data.getString("tags");
    auto modeStr = data.getString("shareMode");
    if (modeStr.length > 0) {
      r.shareMode = modeStr.toShareMode;
    }
    auto result = _usecase.create(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Data product created successfully", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto result = _usecase.list(tenantId);

    auto list = result.map!(item => item.toJson()).array.toJson;
    auto responseData = Json.emptyObject
      .set("count", result.length)
      .set("resources", list);
    return successResponse("Data product list retrieved successfully", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = DataProductId(req.requestPath.to!string.split("/")[$ - 1]);
    auto result = _usecase.get(tenantId, id);
    if (result.isNull)
      return errorResponse("Data product not found", 404);

    auto responseData = result.toJson();
    return successResponse("Data product retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    UpdateDataProductRequest r;
    r.tenantId = tenantId;
    r.id = DataProductId(req.requestPath.to!string.split("/")[$ - 1]);
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.version_ = data.getString("version");
    r.targetCatalog = data.getString("targetCatalog");
    r.targetSchema = data.getString("targetSchema");
    r.tags = data.getString("tags");
    auto modeStr = data.getString("shareMode");
    if (modeStr.length > 0) {
      import std.conv : ConvException;

      try {
        r.shareMode = modeStr.to!ShareMode;
      } catch (ConvException) {
      }
    }
    auto result = _usecase.update(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Data product updated successfully", "Updated", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = req.requestPath.to!string.split("/")[$ - 1];
    auto result = _usecase.remove(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Data product deleted successfully", 200, responseData);
  }
}
