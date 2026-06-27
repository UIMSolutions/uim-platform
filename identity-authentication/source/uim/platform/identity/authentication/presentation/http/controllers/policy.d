/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.authentication.presentation.http.controllers.policy;

// import uim.platform.identity.authentication.application.usecases.manage.policies;
// import uim.platform.identity.authentication.application.dto;
// import uim.platform.identity.authentication.domain.entities.policy;

import uim.platform.identity.authentication;

// mixin(ShowModule!());
@safe:
/// HTTP controller for authorization policy management.
class PolicyController : ManageHttpController {
  private ManagePoliciesUseCase useCase;

  this(ManagePoliciesUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/policies", &handleCreate);
    router.get("/api/v1/policies", &handleList);
    router.get("/api/v1/policies/*", &handleGet);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    ScanJobDTO dto;
    dto.tenantId = tenantId;
    PolicyRule[] rules;
    foreach (rj; rulesJson.toArray) {
      PolicyRule rule;
      rule.attribute = getString(rj, "attribute");
      rule.operator = getString(rj, "operator");
      rule.value = getString(rj, "value");

      rules ~= rule;
    }

    auto createReq = CreatePolicyRequest(data.getString("tenantId"), data.getString("name"),
      data.getString("description"), rules, data.getStrings("applicationIds"));

    auto result = useCase.createPolicy(createReq);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto response = Json.emptyObject;

    response["policyId"] = Json(result.policyId);
    return successResponse("Policy created successfully", "Created", 201, response);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto policies = useCase.listPolicies(tenantId);
    auto arr = policies.map!(p => p.toJson).array;

    auto response = Json.emptyObject
      .set("totalResults", policies.length)
      .set("resources", arr);

    return successResponse("Policies retrieved successfully", "OK", 200, response);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    // import std.string : lastIndexOf;

    auto path = req.requestURI;
    auto idx = path.lastIndexOf('/');
    auto policyId = idx >= 0 ? path[idx + 1 .. $] : "";

    auto tenantId = precheck.tenantId;
    auto policy = useCase.getPolicy(tenantId, policyId);
    if (policy.isNull)
      return errorResponse("Policy not found", 404);

    return successResponse("Policy retrieved successfully", "OK", 200, policy.toJson);
  }
}
