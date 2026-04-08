/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.channel;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.channel;
import uim.platform.workzone.domain.ports.repositories.channels;

// import std.algorithm : filter;
// import std.array : array;

class MemoryChannelRepository : ChannelRepository {
  private Channel[ChannelId] store;

  Channel[] findByWorkspace(WorkspaceId workspaceId, TenantId tenantId) {
    return store.byValue().filter!(c => c.tenantId == tenantId && c.workspaceId == workspaceId)
      .array;
  }

  Channel* findById(ChannelId id, TenantId tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  void save(Channel channel) {
    store[channel.id] = channel;
  }

  void update(Channel channel) {
    store[channel.id] = channel;
  }

  void remove(ChannelId id, TenantId tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}
