/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.infrastructure.persistence.memory.content_connectors;

import uim.platform.automation_pilot;

// mixin(ShowModule!());

@safe:

class MemoryContentConnectorRepository : TenantRepository!(ContentConnector, ContentConnectorId), ContentConnectorRepository {

    size_t countByType(TenantId tenantId, ConnectorType connectorType) {
        return findByType(tenantId, connectorType).length;
    }

    ContentConnector[] filterByType(ContentConnector[] connectors, ConnectorType connectorType) {
        return connectors.filter!(c => c.connectorType == connectorType).array;
    }

    ContentConnector[] findByType(TenantId tenantId, ConnectorType connectorType) {
        return filterByType(findByTenant(tenantId), connectorType);
    }

    void removeByType(TenantId tenantId, ConnectorType connectorType) {
        findByType(tenantId, connectorType).each!(e => remove(e));
    }

    size_t countByStatus(TenantId tenantId, ConnectorStatus status) {
        return findByStatus(tenantId, status).length;
    }

    ContentConnector[] filterByStatus(ContentConnector[] connectors, ConnectorStatus status) {
        return connectors.filter!(c => c.status == status).array;
    }

    ContentConnector[] findByStatus(TenantId tenantId, ConnectorStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }

    void removeByStatus(TenantId tenantId, ConnectorStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }

}
