/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.domain.ports.usecases.data_connections;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

interface IManageDataConnectionsUseCase { 

    DataConnection getDataConnection(TenantId tenantId, DataConnectionId id);
    DataConnection[] listDataConnections(TenantId tenantId);
    DataConnection[] listConnections(TenantId tenantId);
    DataConnection[] listDataConnections(TenantId tenantId, ApplicationId applicationId);
    UsecaseResult createDataConnection(DataConnectionDTO dto);
    UsecaseResult updateDataConnection(DataConnectionDTO dto);
    UsecaseResult deleteDataConnection(TenantId tenantId, DataConnectionId id);
    
}
