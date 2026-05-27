module uim.platform.databricks.presentation.http.controllers.sql_warehouses;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

class SqlWarehouseController : ManageController {
private:
  ManageSqlWarehousesUseCase _usecase;

public:
  this(ManageSqlWarehousesUseCase usecase) { _usecase = usecase; }

  override void registerRoutes(URLRouter router) {
    router.post   ("/api/v1/databricks/warehouses",   &handleCreate);
    router.get    ("/api/v1/databricks/warehouses",   &handleList);
    router.get    ("/api/v1/databricks/warehouses/*", &handleGet);
    router.put    ("/api/v1/databricks/warehouses/*", &handleUpdate);
    router.delete_("/api/v1/databricks/warehouses/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateSqlWarehouseRequest r;
      r.tenantId                = req.getTenantId;
      r.id                      = precheck.id;
      r.workspaceId             = j.getString("workspaceId");
      r.name                    = j.getString("name");
      r.numClusters             = j.getInt("numClusters");
      r.autoStopMinutes         = j.getInt("autoStopMinutes");
      r.enablePhoton            = j.getBoolean("enablePhoton");
      r.enableServerlessCompute = j.getBoolean("enableServerlessCompute");
      r.creatorId               = j.getString("creatorId");
      auto typeStr = j.getString("warehouseType");
      if (typeStr.length > 0) {
        import std.conv : to, ConvException;
        try { r.warehouseType = typeStr.to!WarehouseType; } catch (ConvException) {}
      }
      auto sizeStr = j.getString("size");
      if (sizeStr.length > 0) {
        import std.conv : to, ConvException;
        try { r.size = sizeStr.to!WarehouseSize; } catch (ConvException) {}
      }
      auto result = _usecase.create(r);
      if (result.success) res.writeJsonBody(serializeToJson(result.data), 201);
      else writeError(res, 400, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto result = _usecase.list(req.getTenantId);
      res.writeJsonBody(serializeToJson(result.data));
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;
      auto id     = req.requestPath.to!string.split("/")[$-1];
      auto result = _usecase.get(req.getTenantId, id);
      if (result.success) res.writeJsonBody(serializeToJson(result.data));
      else writeError(res, 404, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;
      auto j = req.json;
      UpdateSqlWarehouseRequest r;
      r.tenantId        = req.getTenantId;
      r.id              = req.requestPath.to!string.split("/")[$-1];
      r.name            = j.getString("name");
      r.numClusters     = j.getInt("numClusters");
      r.autoStopMinutes = j.getInt("autoStopMinutes");
      r.enablePhoton    = j.getBoolean("enablePhoton");
      auto sizeStr = j.getString("size");
      if (sizeStr.length > 0) {
        import std.conv : ConvException;
        try { r.size = sizeStr.to!WarehouseSize; } catch (ConvException) {}
      }
      auto result = _usecase.update(r);
      if (result.success) res.writeJsonBody(serializeToJson(result.data));
      else writeError(res, 404, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;
      auto id     = req.requestPath.to!string.split("/")[$-1];
      auto result = _usecase.remove(req.getTenantId, id);
      if (result.success) res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
      else writeError(res, 404, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }
}
