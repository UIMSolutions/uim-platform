/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.presentation.http.controllers.api_rule;




// import uim.platform.kyma.application.usecases.manage.api_rules;
// import uim.platform.kyma.application.dto;
// import uim.platform.kyma.domain.entities.api_rule;
// import uim.platform.kyma.domain.types;
// import uim.platform.kyma.presentation.http
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
class ApiRuleController : ManageController {
  private ManageApiRulesUseCase usecase;

  this(ManageApiRulesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/api-rules", &handleCreate);
    router.get("/api/v1/api-rules", &handleList);
    router.get("/api/v1/api-rules/*", &handleGet);
    router.put("/api/v1/api-rules/*", &handleUpdate);
    router.delete_("/api/v1/api-rules/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateApiRuleRequest r;
      r.namespaceId = j.getString("namespaceId");
      r.environmentId = j.getString("environmentId");
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.serviceName = j.getString("serviceName");
      r.servicePort = j.getInteger("servicePort");
      r.gateway = j.getString("gateway");
      r.host = j.getString("host");
      r.tlsEnabled = j.getBoolean("tlsEnabled", true);
      r.tlsSecretName = j.getString("tlsSecretName");
      r.corsEnabled = j.getBoolean("corsEnabled");
      r.corsAllowOrigins = getStrings(j, "corsAllowOrigins");
      r.corsAllowMethods = getStrings(j, "corsAllowMethods");
      r.corsAllowHeaders = getStrings(j, "corsAllowHeaders");
      r.labels = jsonStrMap(j, "labels");
      r.createdBy = UserId(req.headers.get("X-User-Id", ""));

      // Parse rules array
      r.rules = j.toRuleEntries;

      auto result = usecase.create(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
            .set("id", result.id);

        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.message);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto nsId = req.params.get("namespaceId");
      auto envId = req.params.get("environmentId");

      ApiRule[] items;
      if (!nsId.isEmpty)
        items = usecase.listByNamespace(nsId);
      else if (!envId.isEmpty)
        items = usecase.listByEnvironment(envId);

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

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = precheck.id;
      auto rule = usecase.getApiRule(tenantId, id);
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

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = precheck.id;
      auto j = req.json;
      UpdateApiRuleRequest r;
      r.description = j.getString("description");
      r.serviceName = j.getString("serviceName");
      r.servicePort = j.getInteger("servicePort");
      r.host = j.getString("host");
      r.tlsEnabled = j.getBoolean("tlsEnabled", true);
      r.tlsSecretName = j.getString("tlsSecretName");
      r.corsEnabled = j.getBoolean("corsEnabled");
      r.corsAllowOrigins = getStrings(j, "corsAllowOrigins");
      r.corsAllowMethods = getStrings(j, "corsAllowMethods");
      r.corsAllowHeaders = getStrings(j, "corsAllowHeaders");
      r.labels = jsonStrMap(j, "labels");
      r.rules = j.toRuleEntries;

      auto result = usecase.updateApiRule(tenantId, id, r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.message);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = precheck.id;
      auto result = usecase.deleteApiRule(tenantId, id);
      if (result.success)
        res.writeBody("", 204);
      else
        writeError(res, 404, result.message);
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
