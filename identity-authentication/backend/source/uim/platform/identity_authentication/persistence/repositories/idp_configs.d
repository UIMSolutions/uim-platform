/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.persistence.repositories.idp_configs;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

class IdpConfigRepository : TenantRepository!(IdpConfig, IdpConfigId), IIdpConfigRepository {
  mixin TenantRepositoryTemplate!(IdpConfigRepository, IdpConfig, IdpConfigId);

  bool existsDefault(TenantId tenantId) {
    return !findDefault(tenantId).isNull;
  }

  IdpConfig findDefault(TenantId tenantId) {
    foreach (c; findByTenant(tenantId))
      if (c.isDefault)
        return c;
    return IdpConfig.init;
  }

  void removeDefault(TenantId tenantId) {
    remove(findByTenant(tenantId).filter!(c => c.isDefault).array);
  }

  bool existsByDomainHint(TenantId tenantId, string emailDomain) {
    return !findByDomainHint(tenantId, emailDomain).isNull;
  }

  IdpConfig findByDomainHint(TenantId tenantId, string emailDomain) {
    foreach (c; findByTenant(tenantId))
      if (c.handlesDomain(emailDomain))
        return c;
    return IdpConfig.init;
  }

  void removeByDomainHint(TenantId tenantId, string emailDomain) {
    remove(findByTenant(tenantId).filter!(c => c.handlesDomain(emailDomain)).array);
  }
}
///
unittest {
  assert(tenantRepositoryTest(new IdpConfigRepository()));
}
