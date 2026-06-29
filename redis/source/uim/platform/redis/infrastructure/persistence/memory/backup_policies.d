/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.infrastructure.persistence.memory.backup_policies;

import uim.platform.redis;
import std.algorithm : filter;
import std.array : array;

// mixin(ShowModule!());

@safe:

class MemoryBackupPolicyRepository
    : TenantRepository!(BackupPolicy, BackupPolicyId)
    , BackupPolicyRepository
{
    override BackupPolicy findByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        auto results = findByTenant(tenantId).filter!(e => e.instanceId == instanceId).array;
        return results.length > 0 ? results[0] : BackupPolicy.init;
    }

    override BackupPolicy[] findByStatus(TenantId tenantId, BackupStatus status) {
        return findByTenant(tenantId).filter!(e => e.status == status).array;
    }
}
