/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.presentation.http.tenant_users;

import uim.platform.datasphere_composer;
import vibe.http.server;
import vibe.http.router;


mixin(ShowModule!());

@safe:
class TenantUserController : ManageController {
  private ManageTenantUsersUseCase usecase;

  this(ManageTenantUsersUseCase usecase) { this.usecase = usecase; }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/composer/users",       &handleList);
    router.get("/api/v1/composer/users/*",      &handleGet);
    router.post("/api/v1/composer/users",       &handleCreate);
    router.put("/api/v1/composer/users/*",      &handleUpdate);
    router.delete_("/api/v1/composer/users/*",  &handleDelete);
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
    r.tenantId      = req.getTenantId;
    r.id            = precheck.id;
    r.email         = data.getString("email");
    r.firstName     = data.getString("firstName");
    r.lastName      = data.getString("lastName");
    r.role          = data.getString("role");
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
    r.active    = data.getBoolean("active");
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
