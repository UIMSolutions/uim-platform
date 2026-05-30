module uim.platform.snowflake.presentation.http.snowflake_databases;
import uim.platform.snowflake;
import vibe.http.server;
import vibe.http.router;

mixin(ShowModule!());
@safe:
class SnowflakeDatabaseController : ManageController {
  private ManageSnowflakeDatabasesUseCase usecase;
  this(ManageSnowflakeDatabasesUseCase usecase) { this.usecase = usecase; }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get   ("/api/v1/snowflake/databases",    &handleList);
    router.get   ("/api/v1/snowflake/databases/*",  &handleGet);
    router.post  ("/api/v1/snowflake/databases",    &handleCreate);
    router.put   ("/api/v1/snowflake/databases/*",  &handleUpdate);
    router.delete_("/api/v1/snowflake/databases/*", &handleDelete);
  }

  void handleList(HTTPServerRequest req, HTTPServerResponse res) {
    auto items = usecase.list(req.getTenantId);
    auto arr = Json.emptyArray;
    foreach (item; items) arr ~= item.toJson();
    res.writeJsonBody(arr, cast(int) HTTPStatus.ok);
  }

  void handleGet(HTTPServerRequest req, HTTPServerResponse res) {
    auto item = usecase.getById(req.getTenantId, extractIdFromPath(req.requestPath.to!string));
    if (item.isNull) { writeError(res, 404, "Database not found"); return; }
    res.writeJsonBody(item.toJson(), cast(int) HTTPStatus.ok);
  }

  void handleCreate(HTTPServerRequest req, HTTPServerResponse res) {
    auto data = precheck.data;
    CreateDatabaseRequest r;
    r.tenantId      = req.getTenantId;
    r.id            = precheck.id;
    r.accountId     = data.getString("accountId");
    r.name          = data.getString("name");
    r.comment       = data.getString("comment");
    if (j["retentionDays"].isInteger) r.retentionDays = cast(int) j["retentionDays"].get!long;
    auto result = usecase.create(r);
    if (!result.success) { writeError(res, 400, result.message); return; }
    auto resp = Json.emptyObject;
    resp["id"] = Json(result.id);
    res.writeJsonBody(resp, cast(int) HTTPStatus.created);
  }

  void handleUpdate(HTTPServerRequest req, HTTPServerResponse res) {
    auto data = precheck.data;
    UpdateDatabaseRequest r;
    r.tenantId = req.getTenantId;
    r.id       = extractIdFromPath(req.requestPath.to!string);
    r.status   = data.getString("status");
    r.comment  = data.getString("comment");
    if (j["retentionDays"].isInteger) r.retentionDays = cast(int) j["retentionDays"].get!long;
    auto result = usecase.update(r);
    if (!result.success) { writeError(res, 400, result.message); return; }
    res.writeJsonBody(Json.emptyObject, cast(int) HTTPStatus.ok);
  }

  void handleDelete(HTTPServerRequest req, HTTPServerResponse res) {
    auto result = usecase.remove(req.getTenantId, extractIdFromPath(req.requestPath.to!string));
    if (!result.success) { writeError(res, 404, result.message); return; }
    res.writeJsonBody(Json.emptyObject, cast(int) HTTPStatus.ok);
  }
}
