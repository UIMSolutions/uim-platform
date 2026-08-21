/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_directory.domain.ports.usecases.password_policies;

import uim.platform.identity_directory;

mixin(ShowModule!());

@safe:
/// Application use case: password policy management.
interface ManagePasswordPoliciesUseCase {

  /// Create a new password policy.
  UsecaseResult createPolicy(CreatePasswordPolicyRequest req);

  /// Get policy by ID.
  PasswordPolicy getPolicy(TenantId tenantId, PasswordPolicyId id) ;

  /// List policies for a tenant.
  PasswordPolicy[] listPolicies(TenantId tenantId);

  /// Get active policy for tenant.
  PasswordPolicy getActivePolicy(TenantId tenantId);

}
