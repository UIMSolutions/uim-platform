/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.domain.ports.repositories.tenants;
// import uim.platform.identity_authentication.domain.entities.tenant;
// import uim.platform.identity_authentication.domain.types;
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// Port: outgoing — tenant persistence.
interface IdMTenantRepository {

  IdMTenant findById(TenantId id);
  IdMTenant findBySubdomain(string subdomain);
  IdMTenant[] findAll(size_t offset = 0, size_t limit = 100);

  void save(IdMTenant tenant);
  void update(IdMTenant tenant);
  void remove(IdMTenant tenant);

}
