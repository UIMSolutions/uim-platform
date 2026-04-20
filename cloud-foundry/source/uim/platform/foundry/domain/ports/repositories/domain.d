/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.ports.repositories.domain;

// import uim.platform.foundry.domain.types;
// import uim.platform.foundry.domain.entities.cf_domain;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:
/// Port for persisting and querying Cloud Foundry domains.
interface IDomainRepository {
  CfDomain[] findByOrg(OrgId orgtenantId, id tenantId);
  CfDomain* findById(DomainId tenantId, id tenantId);
  CfDomain* findByName(TenantId tenantId, string name);
  CfDomain[] findShared(TenantId tenantId);
  CfDomain[] findByTenant(TenantId tenantId);
  void save(CfDomain domain);
  void update(CfDomain domain);
  void remove(DomainId tenantId, id tenantId);
}
