/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.presentation.http.controllers.api_rule;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

// import uim.platform.kyma.application.usecases.manage.api_rules;
// import uim.platform.kyma.application.dto;
// import uim.platform.kyma.domain.entities.api_rule;
// import uim.platform.kyma.domain.types;
// import uim.platform.kyma.presentation.http
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
class ApiRuleController : PlatformController {
  private ManageApiRulesUseCase uc;

  this(ManageApiRulesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/api-rules", &handleCreate);
    router.get("/api/v1/api-rules", &handleList);
    router.get("/api/v1/api-rules/*", &handleGetById);
    router.put("/api/v1/api-rules/*", &handleUpdate);
    router.delete_("/api/v1/api-rules/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateApiRuleRequest r;
      r.namespaceId = j.getString("namespaceId");
      r.environmentId = j.getString("environmentId");
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.serviceName = j.getString("serviceName");
      r.servicePort = j.getInteger("servicePort");
      r.gateway = j.getString("gateway");
      r.host = j.getString("host");
      r.tlsEnabled = j.getBoolean("tlsEnabled", true);
      r.tlsSecretName = j.getString("tlsSecretName");
      r.corsEnabled = j.getBoolean("corsEnabled");
      r.corsAllowOrigins = getStringArray(j, "corsAllowOrigins");
      r.corsAllowMethods = getStringArray(j, "corsAllowMethods");
      r.corsAllowHeaders = getStringArray(j, "corsAllowHeaders");
      r.labels = jsonStrMap(j, "labels");
      r.createdBy = req.headers.get("X-User-Id", "");

      // Parse rules array
      r.rules = j.toRuleEntries;

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
            .set("id", result.id);

        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto nsId = req.params.get("namespaceId");
      auto envId = req.params.get("environmentId");

      ApiRule[] items;
      if (nsId.length > 0)
        items = uc.listByNamespace(nsId);
      else if (envId.length > 0)
        items = uc.listByEnvironment(envId);
      else
        items = [];

      auto arr = items.map!(rule => rule.toJson).array.toJson;

      auto resp = Json.emptyObject
          .set("items", arr)
          .set("totalCount", items.length)
          .set("message", "API rules retrieved successfully");
      
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto rule = uc.getApiRule(id);
      if (rule.isNull) {
        writeError(res, 404, "API rule not found");
        return;
      }
      res.writeJsonBody(rule.toJson, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      UpdateApiRuleRequest r;
      r.description = j.getString("description");
      r.serviceName = j.getString("serviceName");
      r.servicePort = j.getInteger("servicePort");
      r.host = j.getString("host");
      r.tlsEnabled = j.getBoolean("tlsEnabled", true);
      r.tlsSecretName = j.getString("tlsSecretName");
      r.corsEnabled = j.getBoolean("corsEnabled");
      r.corsAllowOrigins = getStringArray(j, "corsAllowOrigins");
      r.corsAllowMethods = getStringArray(j, "corsAllowMethods");
      r.corsAllowHeaders = getStringArray(j, "corsAllowHeaders");
      r.labels = jsonStrMap(j, "labels");
      r.rules = j.toRuleEntries;

      auto result = uc.updateApiRule(id, r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.deleteApiRule(id);
      if (result.success)
        res.writeBody("", 204);
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  

  private Json serializeRule(ApiRule rule) {
    auto json = Json.emptyObject
    .set("id", rule.id)
    .set("namespaceId", rule.namespaceId)
    .set("environmentId", rule.environmentId)
    .set("tenantId", rule.tenantId)
    .set("name", rule.name)
    .set("description", rule.description)
    .set("status", rule.status.to!string)
    .set("serviceName", rule.serviceName)
    .set("servicePort", rule.servicePort)
    .set("gateway", rule.gateway)
    .set("host", rule.host)
    .set("tlsEnabled", rule.tlsEnabled)
    .set("corsEnabled", rule.corsEnabled)
    .set("labels", serializeStrMap(rule.labels))
    .set("createdBy", rule.createdBy)
    .set("createdAt", rule.createdAt)
    .set("updatedAt", rule.updatedAt);

    auto rulesArr = Json.emptyArray;
    foreach (entry; rule.rules) {
      auto mArr = Json.emptyArray;
      foreach (m; entry.methods)
        mArr ~= Json(m.to!string);

      auto ej = Json.emptyObject
      .set("path", entry.path)
      .set("accessStrategy", entry.accessStrategy.to!string)
      .set("requiredScopes", entry.requiredScopes.toJson)
      .set("audiences", entry.audiences.toJson)
      .set("methods", mArr);

      rulesArr ~= ej;
    }
    json["rules"] = rulesArr;

    return json;
  }
}
