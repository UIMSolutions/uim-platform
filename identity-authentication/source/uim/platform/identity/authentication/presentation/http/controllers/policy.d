/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.presentation.http.controllers.policy;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import uim.platform.identity_authentication.application.usecases.manage.policies;
// import uim.platform.identity_authentication.application.dto;
// import uim.platform.identity_authentication.domain.entities.policy;
// import uim.platform.identity_authentication.presentation.http.json_utils;

import uim.platform.identity_authentication;

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

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;

      PolicyRule[] rules;
      auto rulesJson = "rules" in j;
      if (rulesJson !is null && (*rulesJson).type == Json.Type.array) {
        foreach (rj; *rulesJson)
        {
          rules ~= PolicyRule(jsonStr(rj, "attribute"), jsonStr(rj,
              "operator"), jsonStr(rj, "value"));
        }
      }

      auto createReq = CreatePolicyRequest(j.getString("tenantId"), j.getString("name"),
          j.getString("description"), rules, jsonStrArray(j, "applicationIds"));

      auto result = useCase.createPolicy(createReq);
      auto response = Json.emptyObject;

      if (result.isSuccess()) {
        response["policyId"] = Json(result.policyId);
        res.writeJsonBody(response, 201);
      }
      else
      {
        response["error"] = Json(result.error);
        res.writeJsonBody(response, 400);
      }
    }
    catch (Exception e) {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto policies = useCase.listPolicies(tenantId);
      auto response = Json.emptyObject;
      response["totalResults"] = Json(cast(long) policies.length);
      auto arr = Json.emptyArray;
      foreach (p; policies)
        arr ~= toJsonValue(p);
      response["resources"] = arr;
      res.writeJsonBody(response, 200);
    }
    catch (Exception e) {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      // import std.string : lastIndexOf;

      auto path = req.requestURI;
      auto idx = path.lastIndexOf('/');
      auto policyId = idx >= 0 ? path[idx + 1 .. $] : "";

      auto policy = useCase.getPolicy(policyId);
      if (policy == AuthorizationPolicy.init) {
        auto errRes = Json.emptyObject;
        errRes["error"] = Json("Policy not found");
        res.writeJsonBody(errRes, 404);
        return;
      }

      res.writeJsonBody(toJsonValue(policy), 200);
    }
    catch (Exception e) {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }
}
