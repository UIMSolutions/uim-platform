/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.presentation.http.controllers.access_rule;
// import uim.platform.connectivity.application.usecases.manage.access_rules;
// import uim.platform.connectivity.application.dto;
// import uim.platform.connectivity.domain.entities.access_rule;
import uim.platform.connectivity;

// mixin(ShowModule!());

@safe:
class AccessRuleController : ManageHttpController {
  private ManageAccessRulesUseCase usecase;

  this(ManageAccessRulesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/access-rules", &handleCreate);
    router.get("/api/v1/access-rules", &handleList);
    router.get("/api/v1/access-rules/*", &handleGet);
    router.put("/api/v1/access-rules/*", &handleUpdate);
    router.delete_("/api/v1/access-rules/*", &handleDelete);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto rules = usecase.listAccessRules(tenantId);
    auto arr = rules.map!(r => r.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", rules.length);

    return successResponse("Access rules retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    CreateAccessRuleRequest r;
    r.connectorId = data.getString("connectorId");
    r.tenantId = tenantId;
    r.description = data.getString("description");
    r.protocol = data.getString("protocol");
    r.virtualHost = data.getString("virtualHost");
    r.virtualPort = getUshort(data, "virtualPort");
    r.urlPathPrefix = data.getString("urlPathPrefix");
    r.policy = data.getString("policy");
    r.principalPropagation = data.getBoolean("principalPropagation");

    auto result = usecase.createAccessRule(r);
    if (result.hasError)
      return errorResponse(result.message);

    auto responseData = Json.emptyObject
      .set("id", result.id);

    return successResponse("Access rule created successfully", 201, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = RuleId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid access rule ID", 400);

    auto rule = usecase.getAccessRule(tenantId, id);
    return rule.isNull
      ? errorResponse("Access rule not found", 404)
      : successResponse("Access rule retrieved successfully", 200, rule.toJson);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = RuleId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid access rule ID", 400);

    auto data = precheck.data;

    UpdateAccessRuleRequest r;
    r.ruleId = id;
    r.tenantId = tenantId;
    r.description = data.getString("description");
    r.urlPathPrefix = data.getString("urlPathPrefix");
    r.policy = data.getString("policy");
    r.protocol = data.getString("protocol");
    r.virtualHost = data.getString("virtualHost");
    r.virtualPort = getUshort(data, "virtualPort");
    r.principalPropagation = data.getBoolean("principalPropagation");

    auto result = usecase.updateAccessRule(r);
    if (result.hasError)
      return errorResponse(result.message, result.message == "Access rule not found" ? 404 : 400);

    auto responseData = Json.emptyObject
      .set("id", result.id);

    return successResponse("Access rule updated successfully", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = RuleId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid access rule ID", 400);

    auto result = usecase.deleteAccessRule(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, result.message == "Access rule not found" ? 404 : 400);

    auto responseData = Json.emptyObject
      .set("id", result.id);

    return successResponse("Access rule deleted successfully", 200, responseData);
  }
}
