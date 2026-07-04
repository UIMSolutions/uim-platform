module uim.platform.snowflake.presentation.http.snowflake_accounts;
import uim.platform.snowflake;
import vibe.http.server;
import vibe.http.router;

mixin(ShowModule!());
@safe:
class SnowflakeAccountController : ManageHttpController {
  private ManageSnowflakeAccountsUseCase usecase;
  this(ManageSnowflakeAccountsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/snowflake/accounts", &handleList);
    router.get("/api/v1/snowflake/accounts/*", &handleGet);
    router.post("/api/v1/snowflake/accounts", &handleCreate);
    router.put("/api/v1/snowflake/accounts/*", &handleUpdate);
    router.delete_("/api/v1/snowflake/accounts/*", &handleDelete);
    router.post("/api/v1/snowflake/accounts/*/activate", &handleActivate);
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
      writeError(res, 404, "Account not found");
      return;
    }
    res.writeJsonBody(item.toJson(), cast(int)HTTPStatus.ok);
  }

  void handleCreate(HTTPServerRequest req, HTTPServerResponse res) {
    auto data = precheck.data;
    CreateAccountRequest r;
    r.tenantId = tenantId;
    r.id = precheck.id;
    r.name = data.getString("name");
    r.region = data.getString("region");
    r.adminEmail = data.getString("adminEmail");
    r.adminFirstName = data.getString("adminFirstName");
    r.adminLastName = data.getString("adminLastName");
    r.entitlementSystemId = data.getString("entitlementSystemId");
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
    UpdateAccountRequest r;
    r.tenantId = tenantId;
    r.id = extractIdFromPath(req.requestPath.to!string);
    r.name = data.getString("name");
    r.status = data.getString("status");
    auto result = usecase.update(r);
    if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Account updated successfully", "Updated", 200, responseData);
  }

  void handleDelete(HTTPServerRequest req, HTTPServerResponse res) {
    auto result = usecase.remove(req.getTenantId, extractIdFromPath(req.requestPath.to!string));
    if (!result.success) {
      writeError(res, 404, result.message);
      return;
    }
    res.writeJsonBody(Json.emptyObject, cast(int)HTTPStatus.ok);
  }

  void handleActivate(HTTPServerRequest req, HTTPServerResponse res) {
    auto result = usecase.activate(req.getTenantId, extractIdFromPath(req.requestPath.to!string));
    if (!result.success) {
      writeError(res, 404, result.message);
      return;
    }
    res.writeJsonBody(Json.emptyObject, cast(int)HTTPStatus.ok);
  }
}
