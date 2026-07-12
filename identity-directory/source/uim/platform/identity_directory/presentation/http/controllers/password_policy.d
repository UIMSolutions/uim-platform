/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_directory.presentation.http.controllers.password_policy;

// import uim.platform.identity_directory.application.usecases.manage.password_policies;

// import uim.platform.identity_directory.domain.entities.password_policy;
import uim.platform.identity_directory;

mixin(ShowModule!());

@safe:
/// HTTP controller for password policy management.
class PasswordPolicyController : ManageHttpController {
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
    auto request = CreatePasswordPolicyRequest();
    request.tenantId = tenantId;
    request.name = data.getString("name");
    request.description = data.getString("description");
    request.minLength = jsonUint(j, "minLength", 8);
    request.maxLength = jsonUint(j, "maxLength", 128);
    request.requireUppercase = data.getBoolean("requireUppercase", true);
    request.requireLowercase = data.getBoolean("requireLowercase", true);
    request.requireDigit = data.getBoolean("requireDigit", true);
    request.requireSpecialChar = data.getBoolean("requireSpecialChar", true);
    request.minUniqueChars = jsonUint(j, "minUniqueChars", 1);
    request.maxRepeatedChars = jsonUint(j, "maxRepeatedChars", 2);
    request.passwordHistoryCount = jsonUint(j, "passwordHistoryCount", 5);
    request.maxFailedAttempts = jsonUint(j, "maxFailedAttempts", 5);
    request.lockoutDurationMinutes = jsonUint(j, "lockoutDurationMinutes", 30);
    request.expiryDays = jsonUint(j, "expiryDays", 90);

    auto result = useCase.createPolicy(request);
    if (result.hasError)
      return errorResponse(result.errorMessage);

    auto response = Json.emptyObject;
    response["policyId"] = Json(result.policyId);

    return successResponse("Password policy created successfully", "", 201, response);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto policies = useCase.listPolicies(tenantId);
    auto list = policies.map!(p => p.toJson).array;

    auto response = Json.emptyObject
      .set("totalResults", policies.length)
      .set("resources", list);

    return successResponse("Password policies retrieved successfully", "Retrieved", 200, response);
  }

  protected Json getActiveHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto policy = useCase.getActivePolicy(tenantId);
    if (policy.isNull) 
      return errorResponse("No active password policy found", 404);
    
    return successResponse("Active password policy retrieved successfully", "Retrieved", 200, policy
        .toJson);
  }

  mixin(HandleTemplate!("handleGetActive", "getActiveHandler"));

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto policyId = precheck.id;
    auto policy = useCase.getPolicy(policyId);
    if (policy.isNull)
      return errorResponse("Password policy not found", 404);

    return successResponse("Password policy retrieved successfully", "Retrieved", 200, policy
        .toJson);
  }
}
