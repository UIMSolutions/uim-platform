/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.persistence.repositories.import_queue_entries;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

class ImportQueueEntryRepository : TenantRepository!(ImportQueueEntry, ImportQueueEntryId), IImportQueueEntryRepository {
  this() {
    super();
  }

  this(ITenantStore!(ImportQueueEntry, ImportQueueEntryId) store) {
    super(store);
  }

  ImportQueueEntry[] findByNode(TenantId tenantId, TransportNodeId nodeId) {
    return findByTenant(tenantId).filter!(e => e.nodeId == nodeId).array;
  }

  ImportQueueEntry[] findByRequest(TenantId tenantId, TransportRequestId requestId) {
    return findByTenant(tenantId).filter!(e => e.requestId == requestId).array;
  }

  ImportQueueEntry[] findByStatus(TenantId tenantId, ImportStatus status) {
    return findByTenant(tenantId).filter!(e => e.status == status).array;
  }

  ImportQueueEntry[] findByNodeAndStatus(TenantId tenantId, TransportNodeId nodeId, ImportStatus status) {
    return findByTenant(tenantId).filter!(e => e.nodeId == nodeId && e.status == status).array;
  }

  ImportQueueEntry findPending(TenantId tenantId, TransportNodeId nodeId, TransportRequestId requestId) {
    foreach (e; findByTenant(tenantId))
      if (e.nodeId == nodeId && e.requestId == requestId && (e.isPending || e.status == ImportStatus.running))
        return e;
    return ImportQueueEntry.init;
  }

  int maxPosition(TenantId tenantId, TransportNodeId nodeId) {
    int result;
    foreach (e; findByNode(tenantId, nodeId))
      result = max(result, e.queuePosition);
    return result;
  }
}

///
unittest {
  mixin(ShowTest!("ImportQueueEntryRepository"));

  auto repo = new ImportQueueEntryRepository();
  auto e = ImportQueueEntry(TenantId("t1"));
  repo.save(e);
  assert(repo.existsById(TenantId("t1"), e.id));
  assert(repo.countByTenant(TenantId("t1")) == 1);
  repo.remove(e);
  assert(repo.countByTenant(TenantId("t1")) == 0);
}
