module uim.platform.databricks.presentation.http.controllers.data_products;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

class DataProductController : ManageController {
private:
  ManageDataProductsUseCase _usecase;

public:
  this(ManageDataProductsUseCase usecase) { _usecase = usecase; }

  override void registerRoutes(URLRouter router) {
    router.post   ("/api/v1/databricks/dataproducts",   &handleCreate);
    router.get    ("/api/v1/databricks/dataproducts",   &handleList);
    router.get    ("/api/v1/databricks/dataproducts/*", &handleGet);
    router.put    ("/api/v1/databricks/dataproducts/*", &handleUpdate);
    router.delete_("/api/v1/databricks/dataproducts/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateDataProductRequest r;
      r.tenantId      = req.getTenantId;
      r.id            = j.getString("id");
      r.workspaceId   = j.getString("workspaceId");
      r.name          = j.getString("name");
      r.description   = j.getString("description");
      r.provider      = j.getString("provider");
      r.version_      = j.getString("version");
      r.targetCatalog = j.getString("targetCatalog");
      r.targetSchema  = j.getString("targetSchema");
      r.sourceSystemId= j.getString("sourceSystemId");
      r.tags          = j.getString("tags");
      auto modeStr = j.getString("shareMode");
      if (modeStr.length > 0) {
        import std.conv : to, ConvException;
        try { r.shareMode = modeStr.to!ShareMode; } catch (ConvException) {}
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
      UpdateDataProductRequest r;
      r.tenantId     = req.getTenantId;
      r.id           = req.requestPath.to!string.split("/")[$-1];
      r.description  = j.getString("description");
      r.version_     = j.getString("version");
      r.targetCatalog= j.getString("targetCatalog");
      r.targetSchema = j.getString("targetSchema");
      r.tags         = j.getString("tags");
      auto modeStr   = j.getString("shareMode");
      if (modeStr.length > 0) {
        import std.conv : ConvException;
        try { r.shareMode = modeStr.to!ShareMode; } catch (ConvException) {}
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
