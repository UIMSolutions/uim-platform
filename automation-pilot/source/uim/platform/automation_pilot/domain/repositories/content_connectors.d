/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.domain.repositories.content_connectors;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

interface ContentConnectorRepository {
    bool existsById(ContentConnectorId id);
    ContentConnector findById(ContentConnectorId id);

    ContentConnector[] findAll();
    ContentConnector[] findByTenant(TenantId tenantId);
    ContentConnector[] findByType(ConnectorType connectorType);
    ContentConnector[] findByStatus(ConnectorStatus status);

    void save(ContentConnector connector);
    void update(ContentConnector connector);
    void remove(ContentConnectorId id);
}
