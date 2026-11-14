/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.persistence.repositories.transport_requests;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

class TransportRequestRepository : TenantRepository!(TransportRequest, TransportRequestId), ITransportRequestRepository {
  this() {
    super();
  }

  this(ITenantStore!(TransportRequest, TransportRequestId) store) {
    super(store);
  }

  TransportRequest[] findByStatus(TenantId tenantId, RequestStatus status) {
    return findByTenant(tenantId).filter!(e => e.status == status).array;
  }

  TransportRequest[] findBySourceNode(TenantId tenantId, TransportNodeId nodeId) {
    return findByTenant(tenantId).filter!(e => e.sourceNodeId == nodeId).array;
  }

  TransportRequest[] findByContentType(TenantId tenantId, ContentType contentType) {
    return findByTenant(tenantId).filter!(e => e.contentType == contentType).array;
  }
}

///
unittest {
  mixin(ShowTest!("TransportRequestRepository"));

  auto repo = new TransportRequestRepository();
  auto e = TransportRequest(TenantId("t1"));
  repo.save(e);
  assert(repo.existsById(TenantId("t1"), e.id));
  assert(repo.countByTenant(TenantId("t1")) == 1);
  repo.remove(e);
  assert(repo.countByTenant(TenantId("t1")) == 0);
}
