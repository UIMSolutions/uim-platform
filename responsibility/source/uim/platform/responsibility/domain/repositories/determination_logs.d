/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.domain.repositories.determination_logs;

import uim.platform.responsibility;

// mixin(ShowModule!());

@safe:

interface DeterminationLogRepository : ITenantRepository!(DeterminationLog, DeterminationLogId) {
    DeterminationLog[] findByContext(TenantId tenantId, string contextId);
    DeterminationLog[] findByObject(TenantId tenantId, string objectType, string objectId);
    DeterminationLog[] findByStatus(TenantId tenantId, DeterminationStatus status);
    void removeByTenant(TenantId tenantId);
}
