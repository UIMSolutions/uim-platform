/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.infrastructure.persistence.memory.provisioning_jobs;

import uim.platform.identity;

// mixin(ShowModule!());

@safe:

class MemoryProvisioningJobRepository : TenantRepository!(ProvisioningJob, ProvisioningJobId), ProvisioningJobRepository {
    ProvisioningJob[] findByStatus(TenantId tenantId, JobStatus status) {
        return find(tenantId).filter!(j => j.status == status).array;
    }

    ProvisioningJob[] findByType(TenantId tenantId, JobType type_) {
        return find(tenantId).filter!(j => j.type_ == type_).array;
    }

    ProvisioningJob[] findByTargetSystem(TenantId tenantId, string targetSystem) {
        return find(tenantId).filter!(j => j.targetSystem == targetSystem).array;
    }
}
