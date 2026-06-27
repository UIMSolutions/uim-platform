/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.domain.repositories.backup_policies;

import uim.platform.postgres;

// mixin(ShowModule!());

@safe:

interface BackupPolicyRepository : ITenantRepository!(BackupPolicy, BackupPolicyId) {
    BackupPolicy findByInstance(TenantId tenantId, ServiceInstanceId instanceId);
    BackupPolicy[] findByStatus(TenantId tenantId, BackupStatus status);
}
