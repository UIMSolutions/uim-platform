/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.infrastructure.persistence.memory.channels;

// import uim.platform.connectivity.domain.types;
// import uim.platform.connectivity.domain.entities.service_channel;
// import uim.platform.connectivity.domain.ports.repositories.channels;
// 
// // import std.algorithm : filter;
// // import std.array : array;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

class MemoryChannelRepository : ChannelRepository {
  private ServiceChannel[ChannelId] store;

  ServiceChannel findById(ChannelId id)
  {
    if (auto p = id in store)
      return *p;
    return ServiceChannel.init;
  }

  ServiceChannel[] findByConnector(ConnectorId connectorId)
  {
    return store.byValue().filter!(e => e.connectorId == connectorId).array;
  }

  ServiceChannel[] findByTenant(TenantId tenantId)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  ServiceChannel[] findByStatus(TenantId tenantId, ChannelStatus status)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.status == status).array;
  }

  void save(ServiceChannel entity)
  {
    store[entity.id] = entity;
  }

  void update(ServiceChannel entity)
  {
    store[entity.id] = entity;
  }

  void remove(ChannelId id)
  {
    store.remove(id);
  }
}
