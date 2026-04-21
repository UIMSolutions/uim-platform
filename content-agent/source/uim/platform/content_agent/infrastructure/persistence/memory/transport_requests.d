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
class MemoryTransportRequestRepository : TransportRequestRepository {
  private TransportRequest[TransportRequestId] store;

  bool existsById(TransportRequestId id) {
    return (id in store) !is null;
  }

  TransportRequest findById(TransportRequestId id) {
    auto request = id in store;
    return request is null ? TransportRequest.init : *request;
  }

  TransportRequest[] findAll() {
    TransportRequest[] all;
    foreach (request; store.byValue) {
      all ~= request;
    }
    return all;
  }

  size_t countByTenant(TenantId tenantId) {
    size_t count = 0;
    foreach (request; store.byValue) {
      if (request.tenantId == tenantId) {
        ++count;
      }
    }
    return count;
  }

  TransportRequest[] findByTenant(TenantId tenantId) {
    TransportRequest[] matches;
    foreach (request; store.byValue) {
      if (request.tenantId == tenantId) {
        matches ~= request;
      }
    }
    return matches;
  }

  void removeByTenant(TenantId tenantId) {
    TransportRequestId[] idsToRemove;
    foreach (id, request; store) {
      if (request.tenantId == tenantId) {
        idsToRemove ~= id;
      }
    }

    foreach (id; idsToRemove) {
      store.remove(id);
    }
  }

  size_t countByStatus(TenantId tenantId, TransportStatus status) {
    size_t count = 0;
    foreach (request; store.byValue) {
      if (request.tenantId == tenantId && request.status == status) {
        ++count;
      }
    }
    return count;
  }

  TransportRequest[] findByStatus(TenantId tenantId, TransportStatus status) {
    TransportRequest[] matches;
    foreach (request; store.byValue) {
      if (request.tenantId == tenantId && request.status == status) {
        matches ~= request;
      }
    }
    return matches;
  }

  void removeByStatus(TenantId tenantId, TransportStatus status) {
    TransportRequestId[] idsToRemove;
    foreach (id, request; store) {
      if (request.tenantId == tenantId && request.status == status) {
        idsToRemove ~= id;
      }
    }

    foreach (id; idsToRemove) {
      store.remove(id);
    }
  }

  void save(TransportRequest request) {
    store[request.id] = request;
  }

  void update(TransportRequest request) {
    auto existing = request.id in store;
    if (existing !is null) {
      *existing = request;
    }
  }

  void remove(TransportRequestId id) {
    store.remove(id);
  }
}

unittest {
  auto repo = new MemoryTransportRequestRepository();

  auto tenantA = TenantId("tenant-a");
  auto tenantB = TenantId("tenant-b");

  TransportRequest reqA1;
  reqA1.id = TransportRequestId("tr-a-1");
  reqA1.tenantId = tenantA;
  reqA1.status = TransportStatus.created;

  TransportRequest reqA2;
  reqA2.id = TransportRequestId("tr-a-2");
  reqA2.tenantId = tenantA;
  reqA2.status = TransportStatus.released;

  TransportRequest reqB1;
  reqB1.id = TransportRequestId("tr-b-1");
  reqB1.tenantId = tenantB;
  reqB1.status = TransportStatus.created;

  repo.save(reqA1);
  repo.save(reqA2);
  repo.save(reqB1);

  assert(repo.existsById(reqA1.id));
  assert(repo.findById(reqA1.id).id == reqA1.id);
  assert(repo.countByTenant(tenantA) == 2);
  assert(repo.countByTenant(tenantB) == 1);
  assert(repo.countByStatus(tenantA, TransportStatus.created) == 1);

  auto byTenant = repo.findByTenant(tenantA);
  assert(byTenant.length == 2);

  auto byStatus = repo.findByStatus(tenantA, TransportStatus.released);
  assert(byStatus.length == 1);
  assert(byStatus[0].id == reqA2.id);

  reqA1.status = TransportStatus.cancelled;
  repo.update(reqA1);
  assert(repo.findById(reqA1.id).status == TransportStatus.cancelled);

  repo.removeByStatus(tenantA, TransportStatus.released);
  assert(repo.countByTenant(tenantA) == 1);

  repo.removeByTenant(tenantA);
  assert(repo.countByTenant(tenantA) == 0);
  assert(repo.countByTenant(tenantB) == 1);

  repo.remove(reqB1.id);
  assert(!repo.existsById(reqB1.id));
}
