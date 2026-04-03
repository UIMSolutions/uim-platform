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
interface IdpConfigRepository
{
  IdpConfig findById(string id);
  IdpConfig findDefaultForTenant(TenantId tenantId);
  IdpConfig[] findByTenant(TenantId tenantId);
  IdpConfig findByDomainHint(TenantId tenantId, string emailDomain);
  void save(IdpConfig config);
  void update(IdpConfig config);
  void remove(string id);
}
