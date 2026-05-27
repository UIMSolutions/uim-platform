/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.presentation.http.data_source_configs;

import uim.platform.datasphere_composer;
import vibe.http.server;
import vibe.http.router;
import std.conv : to;

mixin(ShowModule!());

@safe:
class DataSourceConfigController : ManageController {
  private ManageDataSourceConfigsUseCase usecase;

  this(ManageDataSourceConfigsUseCase usecase) { this.usecase = usecase; }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/composer/configs",                          &handleList);
    router.get("/api/v1/composer/configs/*",                        &handleGet);
    router.post("/api/v1/composer/configs",                         &handleCreate);
    router.put("/api/v1/composer/configs/*",                        &handleUpdate);
    router.delete_("/api/v1/composer/configs/*",                    &handleDelete);
    router.post("/api/v1/composer/configs/*/identifierMappings",    &handleAddMapping);
  }

  void handleList(HTTPServerRequest req, HTTPServerResponse res) {
    auto items = usecase.list(req.getTenantId);
    auto arr = Json.emptyArray;
    foreach (item; items) arr ~= item.toJson();
    res.writeJsonBody(arr, cast(int) HTTPStatus.ok);
  }

  void handleGet(HTTPServerRequest req, HTTPServerResponse res) {
    auto item = usecase.getById(req.getTenantId, extractIdFromPath(req.requestPath.to!string));
    if (item.isNull) { writeError(res, 404, "Config not found"); return; }
    res.writeJsonBody(item.toJson(), cast(int) HTTPStatus.ok);
  }

  void handleCreate(HTTPServerRequest req, HTTPServerResponse res) {
    auto j = req.json;
    CreateDataSourceConfigRequest r;
    r.tenantId          = req.getTenantId;
    r.id                = precheck.id;
    r.dataProductId     = j.getString("dataProductId");
    r.providerId        = j.getString("providerId");
    r.qualityRank       = j.getString("qualityRank");
    r.timestampFormat   = j.getString("timestampFormat");
    r.timestampField    = j.getString("timestampField");
    r.timestampCustomPattern = j.getString("timestampCustomPattern");
    r.enabled           = j.getBoolean("enabled");
    r.disabledRuleIds   = j.getStrings("disabledRuleIds");
    auto result = usecase.create(r);
    if (!result.success) { writeError(res, 400, result.message); return; }
    auto resp = Json.emptyObject;
    resp["id"] = Json(result.id);
    res.writeJsonBody(resp, cast(int) HTTPStatus.created);
  }

  void handleUpdate(HTTPServerRequest req, HTTPServerResponse res) {
    auto j = req.json;
    UpdateDataSourceConfigRequest r;
    r.tenantId          = req.getTenantId;
    r.id                = extractIdFromPath(req.requestPath.to!string);
    r.qualityRank       = j.getString("qualityRank");
    r.timestampFormat   = j.getString("timestampFormat");
    r.timestampField    = j.getString("timestampField");
    r.timestampCustomPattern = j.getString("timestampCustomPattern");
    r.enabled           = j.getBoolean("enabled");
    r.disabledRuleIds   = j.getStrings("disabledRuleIds");
    auto result = usecase.update(r);
    if (!result.success) { writeError(res, 400, result.message); return; }
    res.writeJsonBody(Json.emptyObject, cast(int) HTTPStatus.ok);
  }

  void handleAddMapping(HTTPServerRequest req, HTTPServerResponse res) {
    auto j = req.json;
    AddIdentifierMappingRequest r;
    r.tenantId           = req.getTenantId;
    r.configId           = extractIdFromPath(req.requestPath.to!string);
    r.ruleId             = j.getString("ruleId");
    r.ruleAttributeName  = j.getString("ruleAttributeName");
    r.sourceAttributeName = j.getString("sourceAttributeName");
    r.transformationType = j.getString("transformationType");
    auto result = usecase.addIdentifierMapping(r);
    if (!result.success) { writeError(res, 400, result.message); return; }
    res.writeJsonBody(Json.emptyObject, cast(int) HTTPStatus.ok);
  }

  void handleDelete(HTTPServerRequest req, HTTPServerResponse res) {
    auto result = usecase.remove(req.getTenantId, extractIdFromPath(req.requestPath.to!string));
    if (!result.success) { writeError(res, 404, result.message); return; }
    res.writeJsonBody(Json.emptyObject, cast(int) HTTPStatus.ok);
  }
}
