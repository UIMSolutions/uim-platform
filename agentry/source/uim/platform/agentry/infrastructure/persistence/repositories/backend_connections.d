/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.infrastructure.persistence.repositories.backend_connections;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class MemoryBackendConnectionRepository : TenantRepository!(BackendConnection, BackendConnectionId), IBackendConnectionRepository {
    mixin TenantRepositoryTemplate!(MemoryBackendConnectionRepository, BackendConnection, BackendConnectionId);

    // #region ByBackendType 
    size_t countByBackendType(TenantId tenantId, BackendType backendType) {
        return findByBackendType(tenantId, backendType).length;
    }

    BackendConnection[] filterByBackendType(BackendConnection[] connections, BackendType backendType) {
        return connections.filter!(c => c.backendType == backendType).array;
    }

    BackendConnection[] findByBackendType(TenantId tenantId, BackendType backendType) {
        return filterByBackendType(find(tenantId), backendType);
    }

    void removeByBackendType(TenantId tenantId, BackendType backendType) {
        findByBackendType(tenantId, backendType).each!(e => remove(e));
    }
    // #endregion ByBackendType

    // #region ByStatus
    size_t countByStatus(TenantId tenantId, ConnectionStatus status) {
        return findByStatus(tenantId, status).length;
    }

    BackendConnection[] filterByStatus(BackendConnection[] connections, ConnectionStatus status) {
        return connections.filter!(c => c.status == status).array;
    }

    BackendConnection[] findByStatus(TenantId tenantId, ConnectionStatus status) {
        return filterByStatus(find(tenantId), status);
    }

    void removeByStatus(TenantId tenantId, ConnectionStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }
    // #endregion ByStatus
}
///
unittest {
    assert(tenantRepositoryTest(new MemoryBackendConnectionRepository));
}
