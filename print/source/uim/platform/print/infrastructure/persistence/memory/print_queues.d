/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.print.infrastructure.persistence.memory.print_queues;

import uim.platform.print;

// mixin(ShowModule!());

@safe:

class MemoryPrintQueueRepository
    : TentRepository!(PrintQueue, PrintQueueId), PrintQueueRepository {

    PrintQueue[] findByStatus(TenantId tenantId, PrintQueueStatus status) {
        return findByTenant(tenantId).filter!(q => q.status == status).array;
    }

    PrintQueue[] findByPrinter(TenantId tenantId, PrinterId printerId) {
        return findByTenant(tenantId).filter!(q => q.printerId == printerId).array;
    }

    PrintQueue findDefault(TenantId tenantId) {
        auto defaults = findByTenant(tenantId).filter!(q => q.isDefault).array;
        return defaults.length > 0 ? defaults[0] : PrintQueue.init;
    }
}
