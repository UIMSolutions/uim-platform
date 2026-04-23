/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.infrastructure.persistence.memory.content_connectors;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class MemoryContentConnectorRepository : TenantRepository!(ContentConnector, ContentConnectorId), ContentConnectorRepository {

    size_t countByType(ConnectorType connectorType) {
        return findByType(connectorType).length;
    }

    ContentConnector[] findByType(ConnectorType connectorType) {
        return findAll.filter!(e => e.connectorType == connectorType).array;
    }

    void removeByType(ConnectorType connectorType) {
        findByType(connectorType).each!(e => remove(e));
    }

    size_t countByStatus(ConnectorStatus status) {
        return findByStatus(status).length;
    }

    ContentConnector[] findByStatus(ConnectorStatus status) {
        return findAll.filter!(e => e.status == status).array;
    }

    void removeByStatus(ConnectorStatus status) {
        findByStatus(status).each!(e => remove(e));
    }

}
