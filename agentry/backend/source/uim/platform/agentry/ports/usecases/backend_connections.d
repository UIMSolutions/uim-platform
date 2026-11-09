/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.tests.usecases.manage.backend_connections;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

interface IManageBackendConnectionsUseCase {

    BackendConnection getBackendConnection(TenantId tenantId, BackendConnectionId id);
    BackendConnection[] listBackendConnections(TenantId tenantId);
    BackendConnection[] listByBackendType(TenantId tenantId, BackendType backendType);
    BackendConnection[] listByStatus(TenantId tenantId, ConnectionStatus status);
    UsecaseResult createBackendConnection(BackendConnectionDTO dto);
    UsecaseResult updateBackendConnection(BackendConnectionDTO dto);
    UsecaseResult deleteBackendConnection(TenantId tenantId, BackendConnectionId id);

}
