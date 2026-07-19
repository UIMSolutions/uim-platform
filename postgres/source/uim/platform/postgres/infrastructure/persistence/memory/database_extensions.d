/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.infrastructure.persistence.memory.database_extensions;

import uim.platform.postgres;
import std.algorithm : filter, any;
import std.array : array;
mixin(ShowModule!());

@safe:

class MemoryDatabaseExtensionRepository
    : TenantRepository!(DatabaseExtension, DatabaseExtensionId)
    , DatabaseExtensionRepository
{
    override DatabaseExtension[] findByInstance(TenantId t, ServiceInstanceId instanceId) {
        return findByTenant(t).filter!(e => e.instanceId == instanceId).array;
    }
    override DatabaseExtension[] findByStatus(TenantId t, ExtensionStatus status) {
        return findByTenant(t).filter!(e => e.status == status).array;
    }
    override bool extensionExists(TenantId t, ServiceInstanceId instanceId, string extensionName) {
        return findByTenant(t).any!(e => e.instanceId == instanceId && e.extensionName == extensionName);
    }
}
