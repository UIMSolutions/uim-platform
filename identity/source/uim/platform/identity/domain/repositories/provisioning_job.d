/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.domain.repositories.provisioning_job;

import uim.platform.identity;

mixin(ShowModule!());

@safe:

interface ProvisioningJobRepository : ITenantRepository!(ProvisioningJob, ProvisioningJobId) {

    ProvisioningJob[] findByStatus(TenantId tenantId, JobStatus status);
    ProvisioningJob[] findByType(TenantId tenantId, JobType type_);
    ProvisioningJob[] findByTargetSystem(TenantId tenantId, string targetSystem);

}
