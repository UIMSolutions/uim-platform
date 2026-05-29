module uim.platform.snowflake.presentation.http.tenant_users;
import uim.platform.snowflake;
import vibe.http.server;
import vibe.http.router;
import std.conv : to;
mixin(ShowModule!());
@safe:
class SnowflakeTenantUserController : ManageController {
  private ManageSnowflakeTenantUsersUseCase usecase;
  this(ManageSnowflakeTenantUsersUseCase usecase) { this.usecase = usecase; }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get   ("/api/v1/snowflake/users",    &handleList);
    router.get   ("/api/v1/snowflake/users/*",  &handleGet);
    router.post  ("/api/v1/snowflake/users",    &handleCreate);
    router.put   ("/api/v1/snowflake/users/*",  &handleUpdate);
    router.delete_("/api/v1/snowflake/users/*", &handleDelete);
  }

  void handleList(HTTPServerRequest req, HTTPServerResponse res) {
    auto items = usecase.list(req.getTenantId);
    auto arr = Json.emptyArray;
    foreach (item; items) arr ~= item.toJson();
    res.writeJsonBody(arr, cast(int) HTTPStatus.ok);
  }

  void handleGet(HTTPServerRequest req, HTTPServerResponse res) {
    auto item = usecase.getById(req.getTenantId, extractIdFromPath(req.requestPath.to!string));
    if (item.isNull) { writeError(res, 404, "User not found"); return; }
    res.writeJsonBody(item.toJson(), cast(int) HTTPStatus.ok);
  }

  void handleCreate(HTTPServerRequest req, HTTPServerResponse res) {
    auto data = precheck.data;
    CreateTenantUserRequest r;
    r.tenantId       = req.getTenantId;
    r.id             = precheck.id;
    r.email          = data.getString("email");
    r.firstName      = data.getString("firstName");
    r.lastName       = data.getString("lastName");
    r.role           = data.getString("role");
    r.externalUserId = data.getString("externalUserId");
    auto result = usecase.create(r);
    if (!result.success) { writeError(res, 400, result.message); return; }
    auto resp = Json.emptyObject;
    resp["id"] = Json(result.id);
    res.writeJsonBody(resp, cast(int) HTTPStatus.created);
  }

  void handleUpdate(HTTPServerRequest req, HTTPServerResponse res) {
    auto data = precheck.data;
    UpdateTenantUserRequest r;
    r.tenantId  = req.getTenantId;
    r.id        = extractIdFromPath(req.requestPath.to!string);
    r.firstName = data.getString("firstName");
    r.lastName  = data.getString("lastName");
    r.role      = data.getString("role");
    if (j["active"].isBoolean_) r.active = j["active"].get!bool;
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
