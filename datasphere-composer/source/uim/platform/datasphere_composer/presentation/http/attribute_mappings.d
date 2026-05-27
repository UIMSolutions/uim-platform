/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.presentation.http.attribute_mappings;

import uim.platform.datasphere_composer;
import vibe.http.server;
import vibe.http.router;
import std.conv : to;

mixin(ShowModule!());

@safe:
class AttributeMappingController : ManageController {
  private ManageAttributeMappingsUseCase usecase;

  this(ManageAttributeMappingsUseCase usecase) { this.usecase = usecase; }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/composer/mappings",       &handleList);
    router.get("/api/v1/composer/mappings/*",      &handleGet);
    router.post("/api/v1/composer/mappings",       &handleCreate);
    router.put("/api/v1/composer/mappings/*",      &handleUpdate);
    router.delete_("/api/v1/composer/mappings/*",  &handleDelete);
  }

  void handleList(HTTPServerRequest req, HTTPServerResponse res) {
    auto items = usecase.list(req.getTenantId);
    auto arr = Json.emptyArray;
    foreach (item; items) arr ~= item.toJson();
    res.writeJsonBody(arr, cast(int) HTTPStatus.ok);
  }

  void handleGet(HTTPServerRequest req, HTTPServerResponse res) {
    auto item = usecase.getById(req.getTenantId, extractIdFromPath(req.requestPath.to!string));
    if (item.isNull) { writeError(res, 404, "Mapping not found"); return; }
    res.writeJsonBody(item.toJson(), cast(int) HTTPStatus.ok);
  }

  void handleCreate(HTTPServerRequest req, HTTPServerResponse res) {
    auto j = req.json;
    CreateAttributeMappingRequest r;
    r.tenantId            = req.getTenantId;
    r.id                  = precheck.id;
    r.configId            = data.getString("configId");
    r.sourceAttributeName = data.getString("sourceAttributeName");
    r.sourceDataType      = data.getString("sourceDataType");
    r.targetAttributeName = data.getString("targetAttributeName");
    r.targetDataType      = data.getString("targetDataType");
    r.delimiter           = data.getString("delimiter");
    r.sortOrder           = j.getInteger("sortOrder");
    auto result = usecase.create(r);
    if (!result.success) { writeError(res, 400, result.message); return; }
    auto resp = Json.emptyObject;
    resp["id"] = Json(result.id);
    res.writeJsonBody(resp, cast(int) HTTPStatus.created);
  }

  void handleUpdate(HTTPServerRequest req, HTTPServerResponse res) {
    auto j = req.json;
    UpdateAttributeMappingRequest r;
    r.tenantId            = req.getTenantId;
    r.id                  = extractIdFromPath(req.requestPath.to!string);
    r.sourceAttributeName = data.getString("sourceAttributeName");
    r.sourceDataType      = data.getString("sourceDataType");
    r.targetAttributeName = data.getString("targetAttributeName");
    r.targetDataType      = data.getString("targetDataType");
    r.delimiter           = data.getString("delimiter");
    r.sortOrder           = j.getInteger("sortOrder");
    r.active              = j.getBoolean("active");
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
