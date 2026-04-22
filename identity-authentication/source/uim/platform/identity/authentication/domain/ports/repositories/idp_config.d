/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.domain.ports.repositories.idp_config;

// import uim.platform.identity_authentication.domain.entities.idp_config;
// import uim.platform.identity_authentication.domain.types;
import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:
/// Port: outgoing — external IdP configuration persistence.
interface IdpConfigRepository : ITenantRepository!(IdpConfig, IdpConfigId) {

  bool existsDefaultForTenant(TenantId tenantId);
  IdpConfig findDefaultForTenant(TenantId tenantId);
  void removeDefaultForTenant(TenantId tenantId);

  bool existsByDomainHint(TenantId tenantId, string emailDomain);
  IdpConfig findByDomainHint(TenantId tenantId, string emailDomain);
  void removeByDomainHint(TenantId tenantId, string emailDomain);

}
