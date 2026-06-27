module uim.platform.databricks.presentation.http.controllers.delta_tables;
import uim.platform.databricks;

// mixin(ShowModule!());

@safe:

class DeltaTableController : ManageHttpController {
private:
  ManageDeltaTablesUseCase _usecase;

public:
  this(ManageDeltaTablesUseCase usecase) {
    _usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    router.post("/api/v1/databricks/tables", &handleCreate);
    router.get("/api/v1/databricks/tables", &handleList);
    router.get("/api/v1/databricks/tables/*", &handleGet);
    router.put("/api/v1/databricks/tables/*", &handleUpdate);
    router.delete_("/api/v1/databricks/tables/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateDeltaTableRequest r;
    r.tenantId = tenantId;
    r.id = precheck.id;
    r.workspaceId = data.getString("workspaceId");
    r.catalogName = data.getString("catalogName");
    r.schemaName = data.getString("schemaName");
    r.tableName = data.getString("tableName");
    r.storageLocation = data.getString("storageLocation");
    r.comment = data.getString("comment");
    r.ownerId = data.getString("ownerId");
    r.dataSourceFormat = data.getString("dataSourceFormat");
    auto typeStr = data.getString("tableType");
    if (typeStr.length > 0) {
      import std.conv : to, ConvException;

      try {
        r.tableType = typeStr.to!TableType;
      } catch (ConvException) {
      }
    }
    auto result = _usecase.create(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("Delta table created successfully", 201, serializeToJson(result.data));
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto result = _usecase.list(tenantId).map!(item => item.toJson()).array.toJson;

    return successResponse("Delta table list retrieved successfully", 200, Json.emptyObject.set("count", result
        .length).set("resources", result));
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = req.requestPath.to!string.split("/")[$ - 1];
    auto result = _usecase.get(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 404);

    return successResponse("Delta table retrieved successfully", 200, serializeToJson(result.data));
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    UpdateDeltaTableRequest r;
    r.tenantId = tenantId;
    r.id = req.requestPath.to!string.split("/")[$ - 1];
    r.comment = data.getString("comment");
    r.storageLocation = data.getString("storageLocation");
    auto result = _usecase.update(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Delta table updated successfully", 200, responseData);
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
    return successResponse("Delta table deleted successfully", 200, responseData);
  }
}
