/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.infrastructure.persistence.memory.password_policy;

// import uim.platform.identity.directory.domain.entities.password_policy;
// import uim.platform.identity.directory.domain.types;
// import uim.platform.identity.directory.domain.ports.repositories.password_policys;
import uim.platform.identity.directory;

mixin(ShowModule!());

@safe:
/// In-memory adapter for password policy persistence.
class MemoryPasswordPolicyRepository : TenantRepository!(PasswordPolicy, PasswordPolicyId), PasswordPolicyRepository {

  bool existsActiveForTenant(TenantId tenantId) {
    return findByTenant(tenantId).any!(p => p.active);
  }

  PasswordPolicy findActiveForTenant(TenantId tenantId) {
    foreach (p; findByTenant(tenantId)) {
      if (p.active)
        return p;
    }
    return PasswordPolicy.init;
  }

}
