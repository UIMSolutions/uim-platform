module uim.platform.databricks.presentation.http.controllers.delta_tables;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

class DeltaTableController : ManageController {
private:
  ManageDeltaTablesUseCase _usecase;

public:
  this(ManageDeltaTablesUseCase usecase) { _usecase = usecase; }

  override void registerRoutes(URLRouter router) {
    router.post   ("/api/v1/databricks/tables",   &handleCreate);
    router.get    ("/api/v1/databricks/tables",   &handleList);
    router.get    ("/api/v1/databricks/tables/*", &handleGet);
    router.put    ("/api/v1/databricks/tables/*", &handleUpdate);
    router.delete_("/api/v1/databricks/tables/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
      CreateDeltaTableRequest r;
      r.tenantId         = req.getTenantId;
      r.id               = precheck.id;
      r.workspaceId      = data.getString("workspaceId");
      r.catalogName      = data.getString("catalogName");
      r.schemaName       = data.getString("schemaName");
      r.tableName        = data.getString("tableName");
      r.storageLocation  = data.getString("storageLocation");
      r.comment          = data.getString("comment");
      r.ownerId          = data.getString("ownerId");
      r.dataSourceFormat = data.getString("dataSourceFormat");
      auto typeStr = data.getString("tableType");
      if (typeStr.length > 0) {
        import std.conv : to, ConvException;
        try { r.tableType = typeStr.to!TableType; } catch (ConvException) {}
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
      
      auto id     = req.requestPath.to!string.split("/")[$-1];
      auto result = _usecase.get(req.getTenantId, id);
      if (result.success) res.writeJsonBody(serializeToJson(result.data));
      else writeError(res, 404, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      
      auto data = precheck.data;
      UpdateDeltaTableRequest r;
      r.tenantId        = req.getTenantId;
      r.id              = req.requestPath.to!string.split("/")[$-1];
      r.comment         = data.getString("comment");
      r.storageLocation = data.getString("storageLocation");
      auto result = _usecase.update(r);
      if (result.success) res.writeJsonBody(serializeToJson(result.data));
      else writeError(res, 404, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      
      auto id     = req.requestPath.to!string.split("/")[$-1];
      auto result = _usecase.remove(req.getTenantId, id);
      if (result.success) res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
      else writeError(res, 404, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }
}
