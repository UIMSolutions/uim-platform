/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.infrastructure.persistence.memory.resource_groups;
// import uim.platform.ai_core.domain.types;
// import uim.platform.ai_core.domain.entities.resource_group;
// import uim.platform.ai_core.domain.ports.repositories.resource_groups;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:
class MemoryResourceGroupRepository : TenantRepository!(ResourceGroup, ResourceGroupId), ResourceGroupRepository {

  size_t countByStatus(TenantId tenantId, string status) {
    return findByStatus(tenantId, status).length;
  }

  ResourceGroup[] filterByStatus(ResourceGroup[] rgs, string status) {
    return rgs.filter!(rg => rg.status == status).array;
  }

  ResourceGroup[] findByStatus(TenantId tenantId, string status) {
    return filterByStatus(findByTenant(tenantId), status);
  }

  void removeByStatus(TenantId tenantId, string status) {
    findByStatus(tenantId, status).each!(rg => remove(rg));
  }
}
