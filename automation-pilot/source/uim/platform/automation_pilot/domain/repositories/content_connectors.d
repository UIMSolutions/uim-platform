/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.domain.repositories.content_connectors;

import uim.platform.automation_pilot;

// mixin(ShowModule!());

@safe:

interface ContentConnectorRepository : ITentRepository!(ContentConnector, ContentConnectorId) {

    size_t countByType(TenantId tenantId, ConnectorType connectorType);
    ContentConnector[] findByType(TenantId tenantId, ConnectorType connectorType);
    void removeByType(TenantId tenantId, ConnectorType connectorType);

    size_t countByStatus(TenantId tenantId, ConnectorStatus status);
    ContentConnector[] findByStatus(TenantId tenantId, ConnectorStatus status);
    void removeByStatus(TenantId tenantId, ConnectorStatus status);

}
