module uim.platform.snowflake.presentation.http.zerocopy_connectors;
import uim.platform.snowflake;
import vibe.http.server;
import vibe.http.router;

mixin(ShowModule!());
@safe:
class ZerocopyConnectorController : ManageHttpController {
  private ManageZerocopyConnectorsUseCase usecase;
  this(ManageZerocopyConnectorsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/snowflake/connectors", &handleList);
    router.get("/api/v1/snowflake/connectors/*", &handleGet);
    router.post("/api/v1/snowflake/connectors", &handleCreate);
    router.put("/api/v1/snowflake/connectors/*", &handleUpdate);
    router.delete_("/api/v1/snowflake/connectors/*", &handleDelete);
    router.post("/api/v1/snowflake/connectors/*/enroll", &handleEnroll);
  }

  void handleList(HTTPServerRequest req, HTTPServerResponse res) {
    auto items = usecase.list(req.getTenantId);
    auto arr = Json.emptyArray;
    foreach (item; items)
      arr ~= item.toJson();
    res.writeJsonBody(arr, cast(int)HTTPStatus.ok);
  }

  void handleGet(HTTPServerRequest req, HTTPServerResponse res) {
    auto item = usecase.getById(req.getTenantId, extractIdFromPath(req.requestPath.to!string));
    if (item.isNull) {
      writeError(res, 404, "Connector not found");
      return;
    }
    res.writeJsonBody(item.toJson(), cast(int)HTTPStatus.ok);
  }

  void handleCreate(HTTPServerRequest req, HTTPServerResponse res) {
    auto data = precheck.data;
    CreateConnectorRequest r;
    r.tenantId = req.getTenantId;
    r.id = precheck.id;
    r.accountId = data.getString("accountId");
    r.name = data.getString("name");
    r.invitationLink = data.getString("invitationLink");
    r.bdcTenantId = data.getString("bdcTenantId");
    r.description = data.getString("description");
    auto result = usecase.create(r);
    if (!result.success) {
      writeError(res, 400, result.message);
      return;
    }
    auto resp = Json.emptyObject;
    resp["id"] = Json(result.id);
    res.writeJsonBody(resp, cast(int)HTTPStatus.created);
  }

  void handleUpdate(HTTPServerRequest req, HTTPServerResponse res) {
    auto data = precheck.data;
    UpdateConnectorRequest r;
    r.tenantId = req.getTenantId;
    r.id = extractIdFromPath(req.requestPath.to!string);
    r.name = data.getString("name");
    r.status = data.getString("status");
    r.description = data.getString("description");
    auto result = usecase.update(r);
    if (!result.success) {
      writeError(res, 400, result.message);
      return;
    }
    res.writeJsonBody(Json.emptyObject, cast(int)HTTPStatus.ok);
  }

  void handleDelete(HTTPServerRequest req, HTTPServerResponse res) {
    auto result = usecase.remove(req.getTenantId, extractIdFromPath(req.requestPath.to!string));
    if (!result.success) {
      writeError(res, 404, result.message);
      return;
    }
    res.writeJsonBody(Json.emptyObject, cast(int)HTTPStatus.ok);
  }

  void handleEnroll(HTTPServerRequest req, HTTPServerResponse res) {
    auto data = precheck.data;
    EnrollConnectorRequest r;
    r.tenantId = req.getTenantId;
    r.connectorId = extractIdFromPath(req.requestPath.to!string);
    r.bdcTenantId = data.getString("bdcTenantId");
    auto result = usecase.enroll(r);
    if (!result.success) {
      writeError(res, 404, result.message);
      return;
    }
    res.writeJsonBody(Json.emptyObject, cast(int)HTTPStatus.ok);
  }
}
