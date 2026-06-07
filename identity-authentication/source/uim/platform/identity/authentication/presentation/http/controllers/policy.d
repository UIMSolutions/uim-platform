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
      auto rulesJson = "rules" in j;
      if (rulesJson !is null && (rulesJson).isArray) {
        foreach (rj; *rulesJson) {
          rules ~= PolicyRule(getString(rj, "attribute"), getString(rj,
              "operator"), getString(rj, "value"));
        }
      }

      auto createReq = CreatePolicyRequest(data.getString("tenantId"), data.getString("name"),
        data.getString("description"), rules, data.getStrings("applicationIds"));

      auto result = useCase.createPolicy(createReq);
      auto response = Json.emptyObject;

      if (result.isSuccess()) {
        response["policyId"] = Json(result.policyId);
        res.writeJsonBody(response, 201);
      } else {
        response["error"] = Json(result.message);
        res.writeJsonBody(response, 400);
      }
    } catch (Exception e) {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
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
