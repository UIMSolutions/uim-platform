/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.infrastructure.persistence.repositories.data_connections;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class MemoryDataConnectionRepository : TenantRepository!(DataConnection, DataConnectionId), DataConnectionRepository {

    size_t countByApplication(TenantId tenantId, ApplicationId applicationId) {
        return findByApplication(tenantId, applicationId).length;
    }

    DataConnection[] filterByApplication(DataConnection[] connections, ApplicationId applicationId) {
        return connections.filter!(e => e.applicationId == applicationId).array;
    }

    DataConnection[] findByApplication(TenantId tenantId, ApplicationId applicationId) {
        return filterByApplication(findByTenant(tenantId), applicationId);
    }

    void removeByApplication(TenantId tenantId, ApplicationId applicationId) {
        findByApplication(tenantId, applicationId).each!(e => remove(e));
    }
    
    size_t countByType(TenantId tenantId, ConnectionType type) {
        return findByType(tenantId, type).length;
    }

    DataConnection[] filterByType(DataConnection[] connections, ConnectionType type) {
        return connections.filter!(e => e.connectionType == type).array;
    }
    
    DataConnection[] findByType(TenantId tenantId, ConnectionType type) {
        return findByTenant(tenantId).filter!(e => e.connectionType == type).array;
    }

    void removeByType(TenantId tenantId, ConnectionType type) {
        findByType(tenantId, type).each!(e => remove(e));
    }

    size_t countByStatus(TenantId tenantId, ConnectionStatus status) {
        return findByStatus(tenantId, status).length;
    }

    DataConnection[] filterByStatus(DataConnection[] connections, ConnectionStatus status) {
        return connections.filter!(e => e.status == status).array;
    }

    DataConnection[] findByStatus(TenantId tenantId, ConnectionStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }

    void removeByStatus(TenantId tenantId, ConnectionStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }
}
