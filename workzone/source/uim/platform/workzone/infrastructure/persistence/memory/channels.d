/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.channel;

  // import uim.platform.workzone.domain.types;
  // import uim.platform.workzone.domain.entities.channel;
  // import uim.platform.workzone.domain.ports.repositories.channels;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class MemoryChannelRepository : TenantRepository!(Channel, ChannelId), ChannelRepository {

  size_t countByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    return findByWorkspace(tenantId, workspaceId).length;
  }

  Channel[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    return findByTenant(tenantId).filter!(c => c.workspaceId == workspaceId).array;
  }

  void removeByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    return findByWorkspace(tenantId, workspaceId).each!(c => remove(c));
  }

}
