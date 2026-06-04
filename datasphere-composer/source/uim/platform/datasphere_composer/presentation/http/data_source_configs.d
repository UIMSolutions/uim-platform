/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.presentation.http.data_source_configs;

import uim.platform.datasphere_composer;
import vibe.http.server;
import vibe.http.router;


mixin(ShowModule!());

@safe:
class DataSourceConfigController : ManageHttpController {
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
    auto data = precheck.data;
    CreateDataSourceConfigRequest r;
    r.tenantId          = tenantId;
    r.id                = precheck.id;
    r.dataProductId     = data.getString("dataProductId");
    r.providerId        = data.getString("providerId");
    r.qualityRank       = data.getString("qualityRank");
    r.timestampFormat   = data.getString("timestampFormat");
    r.timestampField    = data.getString("timestampField");
    r.timestampCustomPattern = data.getString("timestampCustomPattern");
    r.enabled           = data.getBoolean("enabled");
    r.disabledRuleIds   = data.getStrings("disabledRuleIds");
    auto result = usecase.create(r);
    if (!result.success) { writeError(res, 400, result.message); return; }
    auto resp = Json.emptyObject;
    resp["id"] = Json(result.id);
    res.writeJsonBody(resp, cast(int) HTTPStatus.created);
  }

  void handleUpdate(HTTPServerRequest req, HTTPServerResponse res) {
    auto data = precheck.data;
    UpdateDataSourceConfigRequest r;
    r.tenantId          = tenantId;
    r.id                = extractIdFromPath(req.requestPath.to!string);
    r.qualityRank       = data.getString("qualityRank");
    r.timestampFormat   = data.getString("timestampFormat");
    r.timestampField    = data.getString("timestampField");
    r.timestampCustomPattern = data.getString("timestampCustomPattern");
    r.enabled           = data.getBoolean("enabled");
    r.disabledRuleIds   = data.getStrings("disabledRuleIds");
    auto result = usecase.update(r);
    if (!result.success) { writeError(res, 400, result.message); return; }
    res.writeJsonBody(Json.emptyObject, cast(int) HTTPStatus.ok);
  }

  void handleAddMapping(HTTPServerRequest req, HTTPServerResponse res) {
    auto data = precheck.data;
    AddIdentifierMappingRequest r;
    r.tenantId           = tenantId;
    r.configId           = extractIdFromPath(req.requestPath.to!string);
    r.ruleId             = data.getString("ruleId");
    r.ruleAttributeName  = data.getString("ruleAttributeName");
    r.sourceAttributeName = data.getString("sourceAttributeName");
    r.transformationType = data.getString("transformationType");
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
