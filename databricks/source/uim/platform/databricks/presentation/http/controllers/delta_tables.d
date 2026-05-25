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

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateDeltaTableRequest r;
      r.tenantId         = req.getTenantId;
      r.id               = j.getString("id");
      r.workspaceId      = j.getString("workspaceId");
      r.catalogName      = j.getString("catalogName");
      r.schemaName       = j.getString("schemaName");
      r.tableName        = j.getString("tableName");
      r.storageLocation  = j.getString("storageLocation");
      r.comment          = j.getString("comment");
      r.ownerId          = j.getString("ownerId");
      r.dataSourceFormat = j.getString("dataSourceFormat");
      auto typeStr = j.getString("tableType");
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
      UpdateDeltaTableRequest r;
      r.tenantId        = req.getTenantId;
      r.id              = req.requestPath.to!string.split("/")[$-1];
      r.comment         = j.getString("comment");
      r.storageLocation = j.getString("storageLocation");
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
