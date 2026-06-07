/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.presentation.http.data_source_configs;

import uim.platform.datasphere_composer;
import vibe.http.server;
import vibe.http.router;

// mixin(ShowModule!());

@safe:
class DataSourceConfigController : ManageHttpController {
  private ManageDataSourceConfigsUseCase usecase;

  this(ManageDataSourceConfigsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/composer/configs", &handleList);
    router.get("/api/v1/composer/configs/*", &handleGet);
    router.post("/api/v1/composer/configs", &handleCreate);
    router.put("/api/v1/composer/configs/*", &handleUpdate);
    router.delete_("/api/v1/composer/configs/*", &handleDelete);
    router.post("/api/v1/composer/configs/*/identifierMappings", &handleAddMapping);
  }

  void handleList(HTTPServerRequest req, HTTPServerResponse res) {
    auto items = usecase.list(req.getTenantId);
    auto arr = Json.emptyArray;
    foreach (item; items)
      arr ~= item.toJson();
    res.writeJsonBody(arr, cast(int)HTTPStatus.ok);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto item = usecase.getById(req.getTenantId, extractIdFromPath(req.requestPath.to!string));
    if (itemisNull)
      return errorResponse("Scan job not found", 404);

    auto responseData = item.toJson();
    return successResponse("Config retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateDataSourceConfigRequest r;
    r.tenantId = tenantId;
    r.id = precheck.id;
    r.dataProductId = data.getString("dataProductId");
    r.providerId = data.getString("providerId");
    r.qualityRank = data.getString("qualityRank");
    r.timestampFormat = data.getString("timestampFormat");
    r.timestampField = data.getString("timestampField");
    r.timestampCustomPattern = data.getString("timestampCustomPattern");
    r.enabled = data.getBoolean("enabled");
    r.disabledRuleIds = data.getStrings("disabledRuleIds");
    auto result = usecase.create(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Config created successfully", "Created", 201, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    UpdateDataSourceConfigRequest r;
    r.tenantId = tenantId;
    r.id = extractIdFromPath(req.requestPath.to!string);
    r.qualityRank = data.getString("qualityRank");
    r.timestampFormat = data.getString("timestampFormat");
    r.timestampField = data.getString("timestampField");
    r.timestampCustomPattern = data.getString("timestampCustomPattern");
    r.enabled = data.getBoolean("enabled");
    r.disabledRuleIds = data.getStrings("disabledRuleIds");
    auto result = usecase.update(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Config updated successfully", "Updated", 200, responseData);
  }

  void handleAddMapping(HTTPServerRequest req, HTTPServerResponse res) {
    auto data = precheck.data;
    AddIdentifierMappingRequest r;
    r.tenantId = tenantId;
    r.configId = extractIdFromPath(req.requestPath.to!string);
    r.ruleId = data.getString("ruleId");
    r.ruleAttributeName = data.getString("ruleAttributeName");
    r.sourceAttributeName = data.getString("sourceAttributeName");
    r.transformationType = data.getString("transformationType");
    auto result = usecase.addIdentifierMapping(r);
    if (!result.success) {
      writeError(res, 400, result.message);
      return;
    }
    res.writeJsonBody(Json.emptyObject, cast(int)HTTPStatus.ok);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto path = precheck.path;
    auto id = DataSourceConfigId(precheck.id);

    auto result = usecase.deleteConfig(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Config deleted successfully", 200, responseData);
  }
}
