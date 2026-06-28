/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.infrastructure.persistence.memory.import_queue_entries;

import uim.platform.transport;

// mixin(ShowModule!());

@safe:

class MemoryImportQueueEntryRepository : TenantRepository!(ImportQueueEntry, ImportQueueEntryId), ImportQueueEntryRepository {

    ImportQueueEntry[] findByNode(TenantId tenantId, TransportNodeId nodeId) {
        return find(tenantId).filter!(e => e.nodeId.value == nodeId.value).array;
    }

    ImportQueueEntry[] findByRequest(TenantId tenantId, TransportRequestId requestId) {
        return find(tenantId).filter!(e => e.requestId.value == requestId.value).array;
    }

    ImportQueueEntry[] findByStatus(TenantId tenantId, ImportStatus status) {
        return find(tenantId).filter!(e => e.status == status).array;
    }

    ImportQueueEntry[] findByNodeAndStatus(TenantId tenantId, TransportNodeId nodeId, ImportStatus status) {
        return find(tenantId).filter!(e => e.nodeId.value == nodeId.value && e.status == status).array;
    }
}
