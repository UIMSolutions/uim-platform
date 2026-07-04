module uim.platform.databricks.presentation.http.controllers.sql_warehouses;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

class SqlWarehouseController : ManageHttpController {
private:
  ManageSqlWarehousesUseCase _usecase;

public:
  this(ManageSqlWarehousesUseCase usecase) {
    _usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    router.post("/api/v1/databricks/warehouses", &handleCreate);
    router.get("/api/v1/databricks/warehouses", &handleList);
    router.get("/api/v1/databricks/warehouses/*", &handleGet);
    router.put("/api/v1/databricks/warehouses/*", &handleUpdate);
    router.delete_("/api/v1/databricks/warehouses/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateSqlWarehouseRequest r;
    r.tenantId = tenantId;
    r.id = precheck.id;
    r.workspaceId = data.getString("workspaceId");
    r.name = data.getString("name");
    r.numClusters = j.getInt("numClusters");
    r.autoStopMinutes = j.getInt("autoStopMinutes");
    r.enablePhoton = data.getBoolean("enablePhoton");
    r.enableServerlessCompute = data.getBoolean("enableServerlessCompute");
    r.creatorId = data.getString("creatorId");
    auto typeStr = data.getString("warehouseType");
    if (typeStr.length > 0) {
      import std.conv : to, ConvException;

      try {
        r.warehouseType = typeStr.to!WarehouseType;
      } catch (ConvException) {
      }
    }
    auto sizeStr = data.getString("size");
    if (sizeStr.length > 0) {
      import std.conv : to, ConvException;

      try {
        r.size = sizeStr.to!WarehouseSize;
      } catch (ConvException) {
      }
    }
    auto result = _usecase.create(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("SQL warehouse created successfully", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto result = _usecase.list(tenantId).map!(w => Json.emptyObject
        .set("id", w.id)
        .set("workspaceId", w.workspaceId)
        .set("name", w.name)
        .set("numClusters", w.numClusters)
        .set("autoStopMinutes", w.autoStopMinutes)
        .set("enablePhoton", w.enablePhoton)
        .set("enableServerlessCompute", w.enableServerlessCompute)
        .set("creatorId", w.creatorId)
        .set("warehouseType", w.warehouseType.to!string)
        .set("size", w.size.to!string)
        .set("createdAt", w.createdAt)
        .set("updatedAt", w.updatedAt));

    return successResponse("SQL warehouses retrieved successfully", 200, result);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = req.requestPath.to!string.split("/")[$ - 1];
    auto result = _usecase.get(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject
      .set("id", result.data.id)
      .set("workspaceId", result.data.workspaceId)
      .set("name", result.data.name)
      .set("numClusters", result.data.numClusters)
      .set("autoStopMinutes", result.data.autoStopMinutes)
      .set("enablePhoton", result.data.enablePhoton)
      .set("enableServerlessCompute", result.data.enableServerlessCompute)
      .set("creatorId", result.data.creatorId)
      .set("warehouseType", result.data.warehouseType.to!string)
      .set("size", result.data.size.to!string)
      .set("createdAt", result.data.createdAt)
      .set("updatedAt", result.data.updatedAt);

    return successResponse("SQL warehouse retrieved successfully", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    UpdateSqlWarehouseRequest r;
    r.tenantId = tenantId;
    r.id = req.requestPath.to!string.split("/")[$ - 1];
    r.name = data.getString("name");
    r.numClusters = j.getInt("numClusters");
    r.autoStopMinutes = j.getInt("autoStopMinutes");
    r.enablePhoton = data.getBoolean("enablePhoton");
    auto sizeStr = data.getString("size");
    if (sizeStr.length > 0) {
      import std.conv : ConvException;

      try {
        r.size = sizeStr.to!WarehouseSize;
      } catch (ConvException) {
      }
    }
    auto result = _usecase.update(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("SQL warehouse updated successfully", 200, responseData);
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
    return successResponse("SQL warehouse deleted successfully", 200, responseData);
  }
}
