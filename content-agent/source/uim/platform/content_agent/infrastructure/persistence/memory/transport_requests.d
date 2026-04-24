/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.infrastructure.persistence.memory.transport_requests;

// import uim.platform.content_agent.domain.types;
// import uim.platform.content_agent.domain.entities.transport_request;
// import uim.platform.content_agent.domain.ports.repositories.transport_requests;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.content_agent;

mixin(ShowModule!());

@safe:
class MemoryTransportRequestRepository : TenantRepository!(TransportRequest, TransportRequestId), TransportRequestRepository {

  size_t countByStatus(TenantId tenantId, TransportStatus status) {
    return findByStatus(tenantId, status).length;
  }

  TransportRequest[] findByStatus(TenantId tenantId, TransportStatus status) {
    return findByTenant(tenantId).filter!(e => e.status == status).array;
  }

  void removeByStatus(TenantId tenantId, TransportStatus status) {
    findByStatus(tenantId, status).each!(e => remove(e));
  }
}
