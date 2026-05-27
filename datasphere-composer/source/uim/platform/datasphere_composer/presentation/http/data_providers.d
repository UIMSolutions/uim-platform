/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.presentation.http.data_providers;

import uim.platform.datasphere_composer;
import vibe.http.server;
import vibe.http.router;
import std.conv : to;

mixin(ShowModule!());

@safe:
class DataProviderController : ManageController {
  private ManageDataProvidersUseCase usecase;

  this(ManageDataProvidersUseCase usecase) { this.usecase = usecase; }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/composer/providers",  &handleList);
    router.get("/api/v1/composer/providers/*", &handleGet);
    router.post("/api/v1/composer/providers", &handleCreate);
    router.put("/api/v1/composer/providers/*", &handleUpdate);
    router.delete_("/api/v1/composer/providers/*", &handleDelete);
  }

  void handleList(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = precheck.tenantId;
    auto items = usecase.list(tenantId);
    auto arr = Json.emptyArray;
    foreach (item; items) arr ~= item.toJson();
    res.writeJsonBody(arr, cast(int) HTTPStatus.ok);
  }

  void handleGet(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = precheck.tenantId;
    auto id = extractIdFromPath(req.requestPath.to!string);
    auto item = usecase.getById(tenantId, id);
    if (item.isNull) { writeError(res, 404, "Data provider not found"); return; }
    res.writeJsonBody(item.toJson(), cast(int) HTTPStatus.ok);
  }

  void handleCreate(HTTPServerRequest req, HTTPServerResponse res) {
    auto data = precheck.data;
    CreateDataProviderRequest r;
    r.tenantId    = req.getTenantId;
    r.id          = precheck.id;
    r.name        = data.getString("name");
    r.description = data.getString("description");
    r.systemType  = data.getString("systemType");
    r.connectionUrl = data.getString("connectionUrl");
    r.region      = data.getString("region");
    auto result = usecase.create(r);
    if (!result.success) { writeError(res, 400, result.message); return; }
    auto resp = Json.emptyObject;
    resp["id"] = Json(result.id);
    res.writeJsonBody(resp, cast(int) HTTPStatus.created);
  }

  void handleUpdate(HTTPServerRequest req, HTTPServerResponse res) {
    auto data = precheck.data;
    UpdateDataProviderRequest r;
    r.tenantId    = req.getTenantId;
    r.id          = extractIdFromPath(req.requestPath.to!string);
    r.name        = data.getString("name");
    r.description = data.getString("description");
    r.status      = data.getString("status");
    r.connectionUrl = data.getString("connectionUrl");
    r.region      = data.getString("region");
    auto result = usecase.update(r);
    if (!result.success) { writeError(res, 400, result.message); return; }
    res.writeJsonBody(Json.emptyObject, cast(int) HTTPStatus.ok);
  }

  void handleDelete(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = precheck.tenantId;
    auto id = extractIdFromPath(req.requestPath.to!string);
    auto result = usecase.remove(tenantId, id);
    if (!result.success) { writeError(res, 404, result.message); return; }
    res.writeJsonBody(Json.emptyObject, cast(int) HTTPStatus.ok);
  }
}
