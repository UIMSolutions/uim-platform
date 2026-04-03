/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.ports.org;

import uim.platform.foundry.domain.types;
import uim.platform.foundry.domain.entities.organization;

/// Port for persisting and querying organizations.
interface IOrgRepository
{
  Organization[] findByTenant(TenantId tenantId);
  Organization* findById(OrgId id, TenantId tenantId);
  Organization* findByName(TenantId tenantId, string name);
  void save(Organization org);
  void update(Organization org);
  void remove(OrgId id, TenantId tenantId);
}
