/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.infrastructure.persistence.memory.backend_connections;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class MemoryBackendConnectionRepository
    : TenantRepository!(BackendConnection, BackendConnectionId), BackendConnectionRepository {

    BackendConnection[] findByBackendType(TenantId tenantId, BackendType backendType) {
        return findByTenant(tenantId).filter!(c => c.backendType == backendType).array;
    }

    BackendConnection[] findByStatus(TenantId tenantId, ConnectionStatus status) {
        return findByTenant(tenantId).filter!(c => c.status == status).array;
    }

    size_t countByStatus(TenantId tenantId, ConnectionStatus status) {
        return findByStatus(tenantId, status).length;
    }
}
