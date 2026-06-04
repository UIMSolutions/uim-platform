module uim.platform.snowflake.presentation.http.snowflake_warehouses;
import uim.platform.snowflake;
import vibe.http.server;
import vibe.http.router;

mixin(ShowModule!());
@safe:
class SnowflakeWarehouseController : ManageHttpController {
  private ManageSnowflakeWarehousesUseCase usecase;
  this(ManageSnowflakeWarehousesUseCase usecase) { this.usecase = usecase; }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get   ("/api/v1/snowflake/warehouses",    &handleList);
    router.get   ("/api/v1/snowflake/warehouses/*",  &handleGet);
    router.post  ("/api/v1/snowflake/warehouses",    &handleCreate);
    router.put   ("/api/v1/snowflake/warehouses/*",  &handleUpdate);
    router.delete_("/api/v1/snowflake/warehouses/*", &handleDelete);
  }

  void handleList(HTTPServerRequest req, HTTPServerResponse res) {
    auto items = usecase.list(req.getTenantId);
    auto arr = Json.emptyArray;
    foreach (item; items) arr ~= item.toJson();
    res.writeJsonBody(arr, cast(int) HTTPStatus.ok);
  }

  void handleGet(HTTPServerRequest req, HTTPServerResponse res) {
    auto item = usecase.getById(req.getTenantId, extractIdFromPath(req.requestPath.to!string));
    if (item.isNull) { writeError(res, 404, "Warehouse not found"); return; }
    res.writeJsonBody(item.toJson(), cast(int) HTTPStatus.ok);
  }

  void handleCreate(HTTPServerRequest req, HTTPServerResponse res) {
    auto data = precheck.data;
    CreateWarehouseRequest r;
    r.tenantId   = tenantId;
    r.id         = precheck.id;
    r.accountId  = data.getString("accountId");
    r.name       = data.getString("name");
    r.size       = data.getString("size");
    r.comment    = data.getString("comment");
    if (j["autoSuspend"].isInteger) r.autoSuspend = cast(int) j["autoSuspend"].get!long;
    if (j["autoResume"].isBoolean_) r.autoResume = j["autoResume"].get!bool;
    auto result = usecase.create(r);
    if (!result.success) { writeError(res, 400, result.message); return; }
    auto resp = Json.emptyObject;
    resp["id"] = Json(result.id);
    res.writeJsonBody(resp, cast(int) HTTPStatus.created);
  }

  void handleUpdate(HTTPServerRequest req, HTTPServerResponse res) {
    auto data = precheck.data;
    UpdateWarehouseRequest r;
    r.tenantId = tenantId;
    r.id       = extractIdFromPath(req.requestPath.to!string);
    r.size     = data.getString("size");
    r.status   = data.getString("status");
    r.comment  = data.getString("comment");
    if (j["autoSuspend"].isInteger) r.autoSuspend = cast(int) j["autoSuspend"].get!long;
    if (j["autoResume"].isBoolean_) r.autoResume = j["autoResume"].get!bool;
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
