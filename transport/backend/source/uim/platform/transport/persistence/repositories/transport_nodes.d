/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.persistence.repositories.transport_nodes;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

class TransportNodeRepository : TenantRepository!(TransportNode, TransportNodeId), ITransportNodeRepository {
  this() {
    super();
  }

  this(ITenantStore!(TransportNode, TransportNodeId) store) {
    super(store);
  }

  size_t countByStatus(TenantId tenantId, NodeStatus status) {
    return findByStatus(tenantId, status).length;
  }

  TransportNode[] findByStatus(TenantId tenantId, NodeStatus status) {
    return findByTenant(tenantId).filter!(e => e.status == status).array;
  }

  TransportNode[] findByType(TenantId tenantId, NodeType nodeType) {
    return findByTenant(tenantId).filter!(e => e.nodeType == nodeType).array;
  }

  TransportNode findByName(TenantId tenantId, string name) {
    foreach (n; findByTenant(tenantId))
      if (n.name == name)
        return n;
    return TransportNode.init;
  }
}

///
unittest {
  mixin(ShowTest!("TransportNodeRepository"));

  auto repo = new TransportNodeRepository();
  auto e = TransportNode(TenantId("t1"));
  repo.save(e);
  assert(repo.existsById(TenantId("t1"), e.id));
  assert(repo.countByTenant(TenantId("t1")) == 1);
  repo.remove(e);
  assert(repo.countByTenant(TenantId("t1")) == 0);
}
