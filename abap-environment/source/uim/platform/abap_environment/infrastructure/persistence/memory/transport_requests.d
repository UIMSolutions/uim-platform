/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.infrastructure.persistence.memory.transport_request;

// import uim.platform.abap_environment.domain.types;
// import uim.platform.abap_environment.domain.entities.transport_request;
// import uim.platform.abap_environment.domain.ports.repositories.transport_request;
// 
// // import std.algorithm : filter;
// // import std.array : array;

import uim.platform.abap_environment;

mixin(ShowModule!());
@safe:

class MemoryTransportRequestRepository : TransportRequestRepository {
  private TransportRequest[TransportRequestId] store;

  TransportRequest* findById(TransportRequestId id) {
    if (auto p = id in store)
      return p;
    return null;
  }

  TransportRequest[] findBySystem(SystemInstanceId systemId) {
    return findAll().filter!(e => e.sourceSystemId == systemId).array;
  }

  TransportRequest[] findByTenant(TenantId tenantId) {
    return findAll().filter!(e => e.tenantId == tenantId).array;
  }

  TransportRequest[] findByStatus(SystemInstanceId systemId, TransportStatus status) {
    return findAll().filter!(e => e.sourceSystemId == systemId && e.status == status).array;
  }

  TransportRequest[] findByOwner(SystemInstanceId systemId, string owner) {
    return findAll().filter!(e => e.sourceSystemId == systemId && e.owner == owner).array;
  }

  void save(TransportRequest request) {
    store[request.id] = request;
  }

  void update(TransportRequest request) {
    store[request.id] = request;
  }

  void remove(TransportRequestId id) {
    store.remove(id);
  }
}
