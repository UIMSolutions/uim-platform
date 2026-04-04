/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.domain.ports.repositories.tenant;

// import uim.platform.identity_authentication.domain.entities.tenant;
// import uim.platform.identity_authentication.domain.types;
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// Port: outgoing — tenant persistence.
interface TenantRepository {
  Tenant findById(TenantId id);
  Tenant findBySubdomain(string subdomain);
  Tenant[] findAll(uint offset = 0, uint limit = 100);
  void save(Tenant tenant);
  void update(Tenant tenant);
  void remove(TenantId id);
}
