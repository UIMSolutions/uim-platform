/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.domain.repositories.data_connections;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

interface DataConnectionRepository : ITenantRepository!(DataConnection, DataConnectionId) {

    size_t countByApplication(TenantId tenantId, ApplicationId applicationId);
    DataConnection[] findByApplication(TenantId tenantId, ApplicationId applicationId);
    void removeByApplication(TenantId tenantId, ApplicationId applicationId);

    size_t countByStatus(TenantId tenantId, ConnectionStatus status);
    DataConnection[] findByStatus(TenantId tenantId, ConnectionStatus status);
    void removeByStatus(TenantId tenantId, ConnectionStatus status);

}
