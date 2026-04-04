/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.infrastructure.persistence.memory
  .in_memory_transport_request_repo;

import uim.platform.content_agent.domain.types;
import uim.platform.content_agent.domain.entities.transport_request;
import uim.platform.content_agent.domain.ports.repositories.transport_requests;

// import std.algorithm : filter;
// import std.array : array;

class MemoryTransportRequestRepository : TransportRequestRepository
{
  private TransportRequest[TransportRequestId] store;

  TransportRequest findById(TransportRequestId id)
  {
    if (auto p = id in store)
      return *p;
    return TransportRequest.init;
  }

  TransportRequest[] findByTenant(TenantId tenantId)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  TransportRequest[] findByStatus(TenantId tenantId, TransportStatus status)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.status == status).array;
  }

  void save(TransportRequest request)
  {
    store[request.id] = request;
  }

  void update(TransportRequest request)
  {
    store[request.id] = request;
  }

  void remove(TransportRequestId id)
  {
    store.remove(id);
  }
}
