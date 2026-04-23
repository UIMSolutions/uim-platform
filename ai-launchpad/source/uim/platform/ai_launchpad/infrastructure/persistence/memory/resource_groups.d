/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.infrastructure.persistence.memory.resource_group;

import uim.platform.ai_launchpad.domain.ports.repositories.resource_groups;
import uim.platform.ai_launchpad.domain.entities.resource_group : ResourceGroup;
import uim.platform.ai_launchpad.domain.types;

class MemoryResourceGroupRepository : IResourceGroupRepository {
  private ResourceGroup[] store;

  void save(ResourceGroup rg) {
    foreach (existing; store) {
      if (existing.id == rg.id && existing.connectionId == rg.connectionId) {
        existing = rg;
        return;
      }
    }
    store ~= rg;
  }

  ResourceGroup findById(ResourceGroupId id, ConnectionId connectionId) {
    foreach (rg; store) {
      if (rg.id == id && rg.connectionId == connectionId) return rg;
    }
    return ResourceGroup.init;
  }

  ResourceGroup[] findByConnection(ConnectionId connectionId) {
    ResourceGroup[] result;
    foreach (rg; store) {
      if (rg.connectionId == connectionId) result ~= rg;
    }
    return result;
  }

  ResourceGroup[] findAll() {
    return store.dup;
  }

  void remove(ResourceGroupId id, ConnectionId connectionId) {
    ResourceGroup[] filtered;
    foreach (rg; store) {
      if (!(rg.id == id && rg.connectionId == connectionId)) filtered ~= rg;
    }
    store = filtered;
  }
}
