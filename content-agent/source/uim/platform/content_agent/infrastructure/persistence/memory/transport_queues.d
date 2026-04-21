/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.infrastructure.persistence.memory.transport_queues;

// import uim.platform.content_agent.domain.types;
// import uim.platform.content_agent.domain.entities.transport_queue;
// import uim.platform.content_agent.domain.ports.repositories.transport_queues;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.content_agent;

mixin(ShowModule!());

@safe:
class MemoryTransportQueueRepository : TenantRepository!(TransportQueue, TransportQueueId) {

  bool existsDefault(TenantId tenantId) {
    foreach (e; findByTenant(tenantId))
      if (e.isDefault)
        return true;
    return false;
  }

  TransportQueue findDefault(TenantId tenantId) {
    foreach (e; findByTenant(tenantId))
      if (e.isDefault)
        return e;
    return TransportQueue.init;
  }

  void removeDefault(TenantId tenantId) {
    foreach (e; findByTenant(tenantId))
      if (e.isDefault)
        remove(e);
  }

  bool existsByName(TenantId tenantId, string name) {
    foreach (e; findByTenant(tenantId))
      if (e.name == name)
        return true;
    return false;
  }

  TransportQueue findByName(TenantId tenantId, string name) {
    foreach (e; findByTenant(tenantId))
      if (e.name == name)
        return e;
    return TransportQueue.init;
  }

  void removeByName(TenantId tenantId, string name) {
    foreach (e; findByTenant(tenantId))
      if (e.name == name)
        remove(e);
  }

}
