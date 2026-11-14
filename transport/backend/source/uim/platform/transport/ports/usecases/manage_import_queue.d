/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.ports.usecases.manage_import_queue;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// Driving port: the import queues of the nodes.
interface IManageImportQueueUseCase {
  UsecaseResult enqueue(EnqueueInput input);
  UsecaseResult selectEntry(TenantId tenantId, ImportQueueEntryId id, bool selected);
  UsecaseResult updateEntryStatus(TenantId tenantId, ImportQueueEntryId id, ImportStatus status, string errorMessage = "");
  /// Put a finished / failed entry back into the queue (status repeating).
  UsecaseResult resetEntry(TenantId tenantId, ImportQueueEntryId id, string performedBy = "");
  UsecaseResult deleteEntry(TenantId tenantId, ImportQueueEntryId id, string performedBy = "");

  bool hasEntry(TenantId tenantId, ImportQueueEntryId id);
  ImportQueueEntry getEntry(TenantId tenantId, ImportQueueEntryId id);
  ImportQueueEntry[] listEntries(TenantId tenantId);
  /// Queue of one node, ordered by queue position.
  ImportQueueEntry[] listEntriesByNode(TenantId tenantId, TransportNodeId nodeId);
  ImportQueueEntry[] listEntriesByNodeAndStatus(TenantId tenantId, TransportNodeId nodeId, ImportStatus status);
  ImportQueueEntry[] listEntriesByRequest(TenantId tenantId, TransportRequestId requestId);
}
