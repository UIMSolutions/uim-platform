/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.ports.repositories.backend_connections;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

interface IBackendConnectionRepository : ITenantRepository!(BackendConnection, BackendConnectionId) {

    size_t countByStatus(TenantId tenantId, ConnectionStatus status);
    BackendConnection[] findByStatus(TenantId tenantId, ConnectionStatus status);
    void removeByStatus(TenantId tenantId, ConnectionStatus status);

    size_t countByBackendType(TenantId tenantId, BackendType backendType);
    BackendConnection[] findByBackendType(TenantId tenantId, BackendType backendType);
    void removeByBackendType(TenantId tenantId, BackendType backendType);

}
