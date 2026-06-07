/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.repositories.backend_connections;

import uim.platform.agentry;

// mixin(ShowModule!());

@safe:

interface BackendConnectionRepository : ITenantRepository!(BackendConnection, BackendConnectionId) {
    BackendConnection[] findByBackendType(TenantId tenantId, BackendType backendType);
    BackendConnection[] findByStatus(TenantId tenantId, ConnectionStatus status);
    size_t countByStatus(TenantId tenantId, ConnectionStatus status);
}
