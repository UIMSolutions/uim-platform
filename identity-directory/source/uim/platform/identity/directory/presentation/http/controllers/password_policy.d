/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.authentication.presentation.http.password_policy;


// import uim.platform.identity.directory.application.usecases.manage.password_policies;
// import uim.platform.identity.directory.application.dto;
// import uim.platform.identity.directory.domain.entities.password_policy;
import uim.platform.identity.directory;

mixin(ShowModule!());

@safe:
/// HTTP controller for password policy management.
class PasswordPolicyController : ManageController {
  private ManagePasswordPoliciesUseCase useCase;

  this(ManagePasswordPoliciesUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v1/password-policies", &handleCreate);
    router.get("/api/v1/password-policies", &handleList);
    router.get("/api/v1/password-policies/active", &handleGetActive);
    router.get("/api/v1/password-policies/*", &handleGet);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
      auto createReq = CreatePasswordPolicyRequest(req.headers.get("X-Tenant-Id", ""),
          data.getString("name"), data.getString("description"), jsonUint(j,
            "minLength", 8), jsonUint(j, "maxLength", 128), data.getBoolean("requireUppercase",
            true), data.getBoolean("requireLowercase", true), data.getBoolean("requireDigit",
            true), data.getBoolean("requireSpecialChar"), jsonUint(j, "minUniqueChars"), jsonUint(j,
            "maxRepeatedChars"), jsonUint(j, "passwordHistoryCount", 5), jsonUint(j,
            "maxFailedAttempts", 5), jsonUint(j, "lockoutDurationMinutes", 30),
          jsonUint(j, "expiryDays"),);

      auto result = useCase.createPolicy(createReq);
      auto response = Json.emptyObject;

      if (result.isSuccess()) {
        response["policyId"] = Json(result.policyId);
        res.writeJsonBody(response, 201);
      }
      else
      {
        response["error"] = Json(result.message);
        res.writeJsonBody(response, 400);
      }
    }
    catch (Exception e) {
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
      response["resources"] = toJsonArray(policies);
      res.writeJsonBody(response, 200);
    }
    catch (Exception e) {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }

  protected void handleActive(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto policy = useCase.getActivePolicy(tenantId);
      if (policy == PasswordPolicy.init) {
        auto errRes = Json.emptyObject;
        errRes["error"] = Json("No active password policy found");
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

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto policyId = precheck.id;
      auto policy = useCase.getPolicy(policyId);
      if (policy == PasswordPolicy.init) {
        auto errRes = Json.emptyObject;
        errRes["error"] = Json("Password policy not found");
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
