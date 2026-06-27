/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.infrastructure.persistence.memory.resource_groups;

// import uim.platform.ai_launchpad.domain.ports.repositories.resource_groups;
// import uim.platform.ai_launchpad.domain.entities.resource_group : ResourceGroup;
// import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad;

// mixin(ShowModule!());

@safe:
class MemoryResourceGroupRepository : TenantRepository!(ResourceGroup, ResourceGroupId), IResourceGroupRepository {

  bool existsById(TenantId tenantId, ConnectionId connectionId, ResourceGroupId id) {
    return findByConnection(tenantId, connectionId).any!(rg => rg.id == id);
  }

  ResourceGroup findById(TenantId tenantId, ConnectionId connectionId, ResourceGroupId id) {
    foreach (rg; findByConnection(tenantId, connectionId)) {
      if (rg.id == id)
        return rg;
    }
    return ResourceGroup.init;
  }

  void removeById(TenantId tenantId, ConnectionId connectionId, ResourceGroupId id) {
    auto rg = findById(tenantId, connectionId, id);
    remove(rg);
  }

  size_t countByConnection(TenantId tenantId, ConnectionId connectionId) {
    return findByConnection(tenantId, connectionId).length;
  }

  ResourceGroup[] findByConnection(TenantId tenantId, ConnectionId connectionId) {
    return filterByConnection(findByTenant(tenantId), connectionId);
  }

  void removeByConnection(TenantId tenantId, ConnectionId connectionId) {
    findByConnection(tenantId, connectionId).each!(rg => remove(rg));
  }

}
