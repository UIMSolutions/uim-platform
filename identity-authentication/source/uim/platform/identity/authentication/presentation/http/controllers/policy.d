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

mixin(ShowModule!());
@safe:
/// HTTP controller for authorization policy management.
class PolicyController : PlatformController {
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

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;

      PolicyRule[] rules;
      auto rulesJson = "rules" in j;
      if (rulesJson !is null && (rulesJson).isArray) {
        foreach (rj; *rulesJson) {
          rules ~= PolicyRule(getString(rj, "attribute"), getString(rj,
              "operator"), getString(rj, "value"));
        }
      }

      auto createReq = CreatePolicyRequest(j.getString("tenantId"), j.getString("name"),
        j.getString("description"), rules, getStrings(j, "applicationIds"));

      auto result = useCase.createPolicy(createReq);
      auto response = Json.emptyObject;

      if (result.isSuccess()) {
        response["policyId"] = Json(result.policyId);
        res.writeJsonBody(response, 201);
      } else {
        response["error"] = Json(result.error);
        res.writeJsonBody(response, 400);
      }
    } catch (Exception e) {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto policies = useCase.listPolicies(tenantId);
      auto response = Json.emptyObject;
      response["totalResults"] = Json(policies.length);
      auto arr = Json.emptyArray;
      foreach (p; policies)
        arr ~= toJsonValue(p);
      response["resources"] = arr;
      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      // import std.string : lastIndexOf;

      auto path = req.requestURI;
      auto idx = path.lastIndexOf('/');
      auto policyId = idx >= 0 ? path[idx + 1 .. $] : "";

      auto tenantId = req.getTenantId;
      auto policy = useCase.getPolicy(tenantId, policyId);
      if (policy == AuthorizationPolicy.init) {
        auto errRes = Json.emptyObject;
        errRes["error"] = Json("Policy not found");
        res.writeJsonBody(errRes, 404);
        return;
      }

      res.writeJsonBody(toJsonValue(policy), 200);
    } catch (Exception e) {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }
}
