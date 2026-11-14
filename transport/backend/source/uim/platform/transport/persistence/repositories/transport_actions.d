/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.persistence.repositories.transport_actions;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

class TransportActionRepository : TenantRepository!(TransportAction, TransportActionId), ITransportActionRepository {
  this() {
    super();
  }

  this(ITenantStore!(TransportAction, TransportActionId) store) {
    super(store);
  }

  TransportAction[] findByNode(TenantId tenantId, TransportNodeId nodeId) {
    return findByTenant(tenantId).filter!(e => e.nodeId == nodeId).array;
  }

  TransportAction[] findByRequest(TenantId tenantId, TransportRequestId requestId) {
    return findByTenant(tenantId).filter!(e => e.requestId == requestId).array;
  }

  TransportAction[] findByType(TenantId tenantId, ActionType actionType) {
    return findByTenant(tenantId).filter!(e => e.actionType == actionType).array;
  }

  TransportAction[] findByStatus(TenantId tenantId, ActionStatus actionStatus) {
    return findByTenant(tenantId).filter!(e => e.actionStatus == actionStatus).array;
  }
}

///
unittest {
  mixin(ShowTest!("TransportActionRepository"));

  auto repo = new TransportActionRepository();
  auto e = TransportAction(TenantId("t1"));
  repo.save(e);
  assert(repo.existsById(TenantId("t1"), e.id));
  assert(repo.countByTenant(TenantId("t1")) == 1);
  repo.remove(e);
  assert(repo.countByTenant(TenantId("t1")) == 0);
}
