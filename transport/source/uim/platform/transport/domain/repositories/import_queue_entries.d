/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.domain.repositories.import_queue_entries;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

interface ImportQueueEntryRepository : ITenantRepository!(ImportQueueEntry, ImportQueueEntryId) {
    ImportQueueEntry[] findByNode(TenantId tenantId, TransportNodeId nodeId);
    ImportQueueEntry[] findByRequest(TenantId tenantId, TransportRequestId requestId);
    ImportQueueEntry[] findByStatus(TenantId tenantId, ImportStatus status);
    ImportQueueEntry[] findByNodeAndStatus(TenantId tenantId, TransportNodeId nodeId, ImportStatus status);
}
