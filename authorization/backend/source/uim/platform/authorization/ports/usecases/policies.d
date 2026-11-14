/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization.ports.usecases.policies;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

/// Driving port: authorization policies.
interface IManagePolicies {
  AuthorizationPolicy createPolicy(CreatePolicyRequest request);
  AuthorizationPolicy updatePolicy(UpdatePolicyRequest request);
  AuthorizationPolicy getPolicy(TenantId tenantId, PolicyId id);
  AuthorizationPolicy[] listPolicies(TenantId tenantId);
  AuthorizationPolicy[] listPolicies(TenantId tenantId, ManagedApplicationId applicationId);
  AuthorizationPolicy enablePolicy(TenantId tenantId, PolicyId id, UserId actor);
  AuthorizationPolicy disablePolicy(TenantId tenantId, PolicyId id, UserId actor);
  /// Deletes the policy and its assignments.
  void deletePolicy(TenantId tenantId, PolicyId id);
  /// Create the missing base policies of an application (idempotent); returns all its base policies.
  AuthorizationPolicy[] seedBasePolicies(TenantId tenantId, ManagedApplicationId applicationId, UserId actor);
}
