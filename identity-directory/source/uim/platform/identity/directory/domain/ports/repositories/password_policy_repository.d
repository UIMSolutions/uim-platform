/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.domain.ports.repositories.password_policys;

import uim.platform.identity.directory.domain.entities.password_policy;
import uim.platform.identity.directory.domain.types;

/// Port: outgoing — password policy persistence.
interface PasswordPolicyRepository : ITenantRepository!(PasswordPolicy, PasswordPolicyId) {

  bool existsActiveForTenant(TenantId tenantId);
  PasswordPolicy findActiveForTenant(TenantId tenantId);
  void removeActiveForTenant(TenantId tenantId);

}
