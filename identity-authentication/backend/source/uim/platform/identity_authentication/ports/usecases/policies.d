/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.ports.usecases.policies;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Driving port: authorization policies.
interface IManagePoliciesUseCase {
  AuthorizationPolicy[] listPolicies(TenantId tenantId);
  AuthorizationPolicy[] listByApplication(TenantId tenantId, ApplicationId appId);
  AuthorizationPolicy getPolicy(TenantId tenantId, PolicyId id);

  UsecaseResult createPolicy(PolicyDTO dto);
  UsecaseResult updatePolicy(PolicyDTO dto);
  UsecaseResult deletePolicy(TenantId tenantId, PolicyId id);

  /// Would the user get access to the application? data: {"granted", "denyingPolicies"}.
  UsecaseResult evaluateAccess(TenantId tenantId, ApplicationId appId, UserId userId, PolicyEvaluationContext ctx);
}
