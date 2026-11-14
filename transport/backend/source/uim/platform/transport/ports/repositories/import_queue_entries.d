/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.ports.repositories.import_queue_entries;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// Driven port: persistence of import queue entries.
interface IImportQueueEntryRepository : ITenantRepository!(ImportQueueEntry, ImportQueueEntryId) {
  ImportQueueEntry[] findByNode(TenantId tenantId, TransportNodeId nodeId);
  ImportQueueEntry[] findByRequest(TenantId tenantId, TransportRequestId requestId);
  ImportQueueEntry[] findByStatus(TenantId tenantId, ImportStatus status);
  ImportQueueEntry[] findByNodeAndStatus(TenantId tenantId, TransportNodeId nodeId, ImportStatus status);
  /// Pending (initial / repeating) entry of a request in a node's queue, or ImportQueueEntry.init.
  ImportQueueEntry findPending(TenantId tenantId, TransportNodeId nodeId, TransportRequestId requestId);
  /// Highest queue position used in a node's queue (0 if empty).
  int maxPosition(TenantId tenantId, TransportNodeId nodeId);
}
