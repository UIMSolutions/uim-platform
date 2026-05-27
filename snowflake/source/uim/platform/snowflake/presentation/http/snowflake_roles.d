module uim.platform.snowflake.presentation.http.snowflake_roles;
import uim.platform.snowflake;
import vibe.http.server;
import vibe.http.router;
import std.conv : to;
mixin(ShowModule!());
@safe:
class SnowflakeRoleController : ManageController {
  private ManageSnowflakeRolesUseCase usecase;
  this(ManageSnowflakeRolesUseCase usecase) { this.usecase = usecase; }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get   ("/api/v1/snowflake/roles",    &handleList);
    router.get   ("/api/v1/snowflake/roles/*",  &handleGet);
    router.post  ("/api/v1/snowflake/roles",    &handleCreate);
    router.put   ("/api/v1/snowflake/roles/*",  &handleUpdate);
    router.delete_("/api/v1/snowflake/roles/*", &handleDelete);
  }

  void handleList(HTTPServerRequest req, HTTPServerResponse res) {
    auto items = usecase.list(req.getTenantId);
    auto arr = Json.emptyArray;
    foreach (item; items) arr ~= item.toJson();
    res.writeJsonBody(arr, cast(int) HTTPStatus.ok);
  }

  void handleGet(HTTPServerRequest req, HTTPServerResponse res) {
    auto item = usecase.getById(req.getTenantId, extractIdFromPath(req.requestPath.to!string));
    if (item.isNull) { writeError(res, 404, "Role not found"); return; }
    res.writeJsonBody(item.toJson(), cast(int) HTTPStatus.ok);
  }

  void handleCreate(HTTPServerRequest req, HTTPServerResponse res) {
    auto j = req.json;
    CreateRoleRequest r;
    r.tenantId    = req.getTenantId;
    r.id          = precheck.id;
    r.accountId   = j.getString("accountId");
    r.name        = j.getString("name");
    r.description = j.getString("description");
    r.privileges  = getStrings(j, "privileges");
    auto result = usecase.create(r);
    if (!result.success) { writeError(res, 400, result.message); return; }
    auto resp = Json.emptyObject;
    resp["id"] = Json(result.id);
    res.writeJsonBody(resp, cast(int) HTTPStatus.created);
  }

  void handleUpdate(HTTPServerRequest req, HTTPServerResponse res) {
    auto j = req.json;
    UpdateRoleRequest r;
    r.tenantId    = req.getTenantId;
    r.id          = extractIdFromPath(req.requestPath.to!string);
    r.description = j.getString("description");
    r.privileges  = getStrings(j, "privileges");
    if (j["active"].type == Json.Type.bool_) r.active = j["active"].get!bool;
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
