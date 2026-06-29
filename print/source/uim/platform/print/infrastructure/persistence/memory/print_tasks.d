/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.print.infrastructure.persistence.memory.print_tasks;

import uim.platform.print;

// mixin(ShowModule!());

@safe:

class MemoryPrintTaskRepository
    : TenantRepository!(PrintTask, PrintTaskId), PrintTaskRepository {

    PrintTask[] findByQueue(TenantId tenantId, PrintQueueId queueId) {
        return findByTenant(tenantId).filter!(t => t.queueId == queueId).array;
    }

    PrintTask[] findByStatus(TenantId tenantId, PrintTaskStatus status) {
        return findByTenant(tenantId).filter!(t => t.status == status).array;
    }

    PrintTask[] findPendingByQueue(TenantId tenantId, PrintQueueId queueId) {
        return findByTenant(tenantId)
            .filter!(t => t.queueId == queueId && t.status == PrintTaskStatus.pending)
            .array;
    }

    size_t countByStatus(TenantId tenantId, PrintTaskStatus status) {
        return findByStatus(tenantId, status).length;
    }
}
