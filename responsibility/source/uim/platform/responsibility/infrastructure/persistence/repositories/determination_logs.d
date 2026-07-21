/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.infrastructure.persistence.repositories.determination_logs;

import uim.platform.responsibility;

mixin(ShowModule!());

@safe:

class MemoryDeterminationLogRepository
    : TenantRepository!(DeterminationLog, DeterminationLogId),
      DeterminationLogRepository {

    DeterminationLog[] findByContext(TenantId tenantId, string contextId) {
        return findByTenant(tenantId).filter!(l => l.contextId == contextId).array;
    }

    DeterminationLog[] findByObject(TenantId tenantId, string objectType, string objectId) {
        return findByTenant(tenantId)
            .filter!(l => l.objectType == objectType && l.objectId == objectId).array;
    }

    DeterminationLog[] findByStatus(TenantId tenantId, DeterminationStatus status) {
        return findByTenant(tenantId).filter!(l => l.status == status).array;
    }

    override void removeByTenant(TenantId tenantId) {
        findByTenant(tenantId).each!(l => remove(l));
    }
}
