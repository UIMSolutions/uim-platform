/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.domain.repositories.builds;

import uim.platform.integration_delivery;

// mixin(ShowModule!());

@safe:

interface BuildRepository : ITenantRepository!(Build, BuildId) {
    Build[] findByJob(TenantId tenantId, JobId jobId);
    Build[] findByStatus(TenantId tenantId, BuildStatus status);
    Build[] findByJobAndStatus(TenantId tenantId, JobId jobId, BuildStatus status);
    Build findLatestByJob(TenantId tenantId, JobId jobId);
}
