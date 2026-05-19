/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.infrastructure.persistence.memory.backup_policies;

import uim.platform.postgres;
import std.algorithm : filter;
import std.array : array;

mixin(ShowModule!());

@safe:

class MemoryBackupPolicyRepository
    : TenantRepository!(BackupPolicy, BackupPolicyId)
    , BackupPolicyRepository
{
    override BackupPolicy findByInstance(TenantId t, ServiceInstanceId instanceId) {
        auto r = findByTenant(t).filter!(e => e.instanceId == instanceId).array;
        return r.length > 0 ? r[0] : BackupPolicy.init;
    }
    override BackupPolicy[] findByStatus(TenantId t, BackupStatus status) {
        return findByTenant(t).filter!(e => e.status == status).array;
    }
}
