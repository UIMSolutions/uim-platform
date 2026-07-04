/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.infrastructure.persistence.memory.translation_jobs;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

class MemoryTranslationJobRepository
    : TenantRepository!(TranslationJob, TranslationJobId),
      TranslationJobRepository
{

    size_t countByStatus(TenantId tenantId, JobStatus status) {
        return findByStatus(tenantId, status).length;
    }
    TranslationJob[] findByStatus(TenantId tenantId, JobStatus status) {
        return findByTenant(tenantId).filter!(j => j.status == status).array;
    }
    void removeByStatus(TenantId tenantId, JobStatus status) {
        findByStatus(tenantId, status).each!((j) => remove(j));
    }

    size_t countPending(TenantId tenantId) {
        return countByStatus(tenantId, JobStatus.pending);
    }
    TranslationJob[] findPending(TenantId tenantId) {
        return findByStatus(tenantId, JobStatus.pending);
    }
    void removePending(TenantId tenantId) {
        removeByStatus(tenantId, JobStatus.pending);
    }
}
