/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.domain.repositories.content_connectors;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

interface ContentConnectorRepository : ITenantRepository!(ContentConnector, ContentConnectorId) {

    size_t countByType(ConnectorType connectorType);
    ContentConnector[] findByType(ConnectorType connectorType);
    void removeByType(ConnectorType connectorType);

    size_t countByStatus(ConnectorStatus status);
    ContentConnector[] findByStatus(ConnectorStatus status);
    void removeByStatus(ConnectorStatus status);

}
