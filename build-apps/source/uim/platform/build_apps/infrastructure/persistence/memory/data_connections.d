/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.infrastructure.persistence.memory.data_connections;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class MemoryDataConnectionRepository : TenantRepository!(DataConnection, DataConnectionId), DataConnectionRepository {

    size_t countByApplication(ApplicationId applicationId) {
        return findByApplication(applicationId).length;
    }

    DataConnection[] findByApplication(ApplicationId applicationId) {
        return findAll.filter!(e => e.applicationId == applicationId).array;
    }

    void removeByApplication(ApplicationId applicationId) {
        findByApplication(applicationId).each!(e => remove(e));
    }
    
    size_t countByType(ConnectionType type) {
        return findByType(type).length;
    }

    DataConnection[] findByType(ConnectionType type) {
        return findAll.filter!(e => e.connectionType == type).array;
    }

    void removeByType(ConnectionType type) {
        findByType(type).each!(e => remove(e));
    }

    size_t countByStatus(ConnectionStatus status) {
        return findByStatus(status).length;
    }

    DataConnection[] findByStatus(ConnectionStatus status) {
        return findAll.filter!(e => e.status == status).array;
    }

    void removeByStatus(ConnectionStatus status) {
        findByStatus(status).each!(e => remove(e));
    }
}
