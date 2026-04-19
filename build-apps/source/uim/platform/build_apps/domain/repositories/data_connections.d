/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.domain.repositories.data_connections;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

interface DataConnectionRepository {
    bool existsById(DataConnectionId id);
    DataConnection findById(DataConnectionId id);

    DataConnection[] findAll();
    DataConnection[] findByTenant(TenantId tenantId);
    DataConnection[] findByApplication(ApplicationId applicationId);
    DataConnection[] findByStatus(ConnectionStatus status);

    void save(DataConnection entity);
    void update(DataConnection entity);
    void remove(DataConnectionId id);
}
