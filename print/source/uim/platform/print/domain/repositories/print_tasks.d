/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.print.domain.repositories.print_tasks;

import uim.platform.print;

// mixin(ShowModule!());

@safe:

interface PrintTaskRepository : ITenantRepository!(PrintTask, PrintTaskId) {
    PrintTask[] findByQueue(TenantId tenantId, PrintQueueId queueId);
    PrintTask[] findByStatus(TenantId tenantId, PrintTaskStatus status);
    PrintTask[] findPendingByQueue(TenantId tenantId, PrintQueueId queueId);
    size_t countByStatus(TenantId tenantId, PrintTaskStatus status);
}
