module uim.platform.snowflake.presentation.http.zerocopy_connectors;
import uim.platform.snowflake;
import vibe.http.server;
import vibe.http.router;
import std.conv : to;
mixin(ShowModule!());
@safe:
class ZerocopyConnectorController : ManageController {
  private ManageZerocopyConnectorsUseCase usecase;
  this(ManageZerocopyConnectorsUseCase usecase) { this.usecase = usecase; }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get   ("/api/v1/snowflake/connectors",         &handleList);
    router.get   ("/api/v1/snowflake/connectors/*",       &handleGet);
    router.post  ("/api/v1/snowflake/connectors",         &handleCreate);
    router.put   ("/api/v1/snowflake/connectors/*",       &handleUpdate);
    router.delete_("/api/v1/snowflake/connectors/*",      &handleDelete);
    router.post  ("/api/v1/snowflake/connectors/*/enroll",&handleEnroll);
  }

  void handleList(HTTPServerRequest req, HTTPServerResponse res) {
    auto items = usecase.list(req.getTenantId);
    auto arr = Json.emptyArray;
    foreach (item; items) arr ~= item.toJson();
    res.writeJsonBody(arr, cast(int) HTTPStatus.ok);
  }

  void handleGet(HTTPServerRequest req, HTTPServerResponse res) {
    auto item = usecase.getById(req.getTenantId, extractIdFromPath(req.requestPath.to!string));
    if (item.isNull) { writeError(res, 404, "Connector not found"); return; }
    res.writeJsonBody(item.toJson(), cast(int) HTTPStatus.ok);
  }

  void handleCreate(HTTPServerRequest req, HTTPServerResponse res) {
    auto j = req.json;
    CreateConnectorRequest r;
    r.tenantId       = req.getTenantId;
    r.id             = j.getString("id");
    r.accountId      = j.getString("accountId");
    r.name           = j.getString("name");
    r.invitationLink = j.getString("invitationLink");
    r.bdcTenantId    = j.getString("bdcTenantId");
    r.description    = j.getString("description");
    auto result = usecase.create(r);
    if (!result.success) { writeError(res, 400, result.message); return; }
    auto resp = Json.emptyObject;
    resp["id"] = Json(result.id);
    res.writeJsonBody(resp, cast(int) HTTPStatus.created);
  }

  void handleUpdate(HTTPServerRequest req, HTTPServerResponse res) {
    auto j = req.json;
    UpdateConnectorRequest r;
    r.tenantId    = req.getTenantId;
    r.id          = extractIdFromPath(req.requestPath.to!string);
    r.name        = j.getString("name");
    r.status      = j.getString("status");
    r.description = j.getString("description");
    auto result = usecase.update(r);
    if (!result.success) { writeError(res, 400, result.message); return; }
    res.writeJsonBody(Json.emptyObject, cast(int) HTTPStatus.ok);
  }

  void handleDelete(HTTPServerRequest req, HTTPServerResponse res) {
    auto result = usecase.remove(req.getTenantId, extractIdFromPath(req.requestPath.to!string));
    if (!result.success) { writeError(res, 404, result.message); return; }
    res.writeJsonBody(Json.emptyObject, cast(int) HTTPStatus.ok);
  }

  void handleEnroll(HTTPServerRequest req, HTTPServerResponse res) {
    auto j = req.json;
    EnrollConnectorRequest r;
    r.tenantId    = req.getTenantId;
    r.connectorId = extractIdFromPath(req.requestPath.to!string);
    r.bdcTenantId = j.getString("bdcTenantId");
    auto result = usecase.enroll(r);
    if (!result.success) { writeError(res, 404, result.message); return; }
    res.writeJsonBody(Json.emptyObject, cast(int) HTTPStatus.ok);
  }
}
