/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.ports.repositories.resource_groups;

// import uim.platform.ai_launchpad.domain.types;
// import uim.platform.ai_launchpad.domain.entities.resource_group : ResourceGroup;
import uim.platform.ai_launchpad;

// mixin(ShowModule!());

@safe:

interface IResourceGroupRepository : ITentRepository!(ResourceGroup, ResourceGroupId) {

  bool existsById(TenantId tenantId, ConnectionId connectionId, ResourceGroupId id);
  ResourceGroup findById(TenantId tenantId, ConnectionId connectionId, ResourceGroupId id);
  void removeById(TenantId tenantId, ConnectionId connectionId, ResourceGroupId id);

  size_t countByConnection(TenantId tenantId, ConnectionId connectionId);
  ResourceGroup[] findByConnection(TenantId tenantId, ConnectionId connectionId);
  void removeByConnection(TenantId tenantId, ConnectionId connectionId);

}
