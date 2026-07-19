/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.print.domain.repositories.print_queues;

import uim.platform.print;

mixin(ShowModule!());

@safe:

interface PrintQueueRepository : ITenantRepository!(PrintQueue, PrintQueueId) {
    PrintQueue[] findByStatus(TenantId tenantId, PrintQueueStatus status);
    PrintQueue[] findByPrinter(TenantId tenantId, PrinterId printerId);
    PrintQueue findDefault(TenantId tenantId);
}
