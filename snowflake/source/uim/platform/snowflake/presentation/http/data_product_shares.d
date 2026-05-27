module uim.platform.snowflake.presentation.http.data_product_shares;
import uim.platform.snowflake;
import vibe.http.server;
import vibe.http.router;
import std.conv : to;
mixin(ShowModule!());
@safe:
class DataProductShareController : ManageController {
  private ManageDataProductSharesUseCase usecase;
  this(ManageDataProductSharesUseCase usecase) { this.usecase = usecase; }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get   ("/api/v1/snowflake/shares",         &handleList);
    router.get   ("/api/v1/snowflake/shares/*",       &handleGet);
    router.post  ("/api/v1/snowflake/shares",         &handleCreate);
    router.put   ("/api/v1/snowflake/shares/*",       &handleUpdate);
    router.delete_("/api/v1/snowflake/shares/*",      &handleDelete);
    router.post  ("/api/v1/snowflake/shares/*/sync",  &handleSync);
  }

  void handleList(HTTPServerRequest req, HTTPServerResponse res) {
    auto items = usecase.list(req.getTenantId);
    auto arr = Json.emptyArray;
    foreach (item; items) arr ~= item.toJson();
    res.writeJsonBody(arr, cast(int) HTTPStatus.ok);
  }

  void handleGet(HTTPServerRequest req, HTTPServerResponse res) {
    auto item = usecase.getById(req.getTenantId, extractIdFromPath(req.requestPath.to!string));
    if (item.isNull) { writeError(res, 404, "Share not found"); return; }
    res.writeJsonBody(item.toJson(), cast(int) HTTPStatus.ok);
  }

  void handleCreate(HTTPServerRequest req, HTTPServerResponse res) {
    auto data = precheck.data;
    CreateShareRequest r;
    r.tenantId      = req.getTenantId;
    r.id            = precheck.id;
    r.accountId     = data.getString("accountId");
    r.connectorId   = data.getString("connectorId");
    r.dataProductId = data.getString("dataProductId");
    r.shareName     = data.getString("shareName");
    r.comment       = data.getString("comment");
    auto result = usecase.create(r);
    if (!result.success) { writeError(res, 400, result.message); return; }
    auto resp = Json.emptyObject;
    resp["id"] = Json(result.id);
    res.writeJsonBody(resp, cast(int) HTTPStatus.created);
  }

  void handleUpdate(HTTPServerRequest req, HTTPServerResponse res) {
    auto data = precheck.data;
    UpdateShareRequest r;
    r.tenantId = req.getTenantId;
    r.id       = extractIdFromPath(req.requestPath.to!string);
    r.status   = data.getString("status");
    r.comment  = data.getString("comment");
    auto result = usecase.update(r);
    if (!result.success) { writeError(res, 400, result.message); return; }
    res.writeJsonBody(Json.emptyObject, cast(int) HTTPStatus.ok);
  }

  void handleDelete(HTTPServerRequest req, HTTPServerResponse res) {
    auto result = usecase.remove(req.getTenantId, extractIdFromPath(req.requestPath.to!string));
    if (!result.success) { writeError(res, 404, result.message); return; }
    res.writeJsonBody(Json.emptyObject, cast(int) HTTPStatus.ok);
  }

  void handleSync(HTTPServerRequest req, HTTPServerResponse res) {
    auto result = usecase.sync_(req.getTenantId, extractIdFromPath(req.requestPath.to!string));
    if (!result.success) { writeError(res, 404, result.message); return; }
    res.writeJsonBody(Json.emptyObject, cast(int) HTTPStatus.ok);
  }
}
