/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.presentation.http.controllers.backend_connection;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

interface IBackendConnectionApi {
    @headerParam("tenantId", "X-Tenant-Id")
    BackendConnection[] listBackendConnections(string tenantId);

    @headerParam("tenantId", "X-Tenant-Id")
    BackendConnection getBackendConnection(string tenantId, BackendConnectionId connectionId);

    @headerParam("tenantId", "X-Tenant-Id")
    void createBackendConnection(string tenantId, BackendConnection connection);

    @headerParam("tenantId", "X-Tenant-Id")
    void updateBackendConnection(string tenantId, BackendConnection connection);

    @headerParam("tenantId", "X-Tenant-Id")
    void deleteBackendConnection(string tenantId, BackendConnectionId connectionId);
}
