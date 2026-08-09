/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.domain.ports.usecases.content_connectors;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

interface IManageContentConnectorsUseCase { 

    ContentConnector getContentConnector(TenantId tenantId, ContentConnectorId id);
    ContentConnector[] listContentConnectors(TenantId tenantId);
    CommandResult createContentConnector(ContentConnectorDTO dto);
    CommandResult updateContentConnector(ContentConnectorDTO dto);
    CommandResult deleteContentConnector(TenantId tenantId, ContentConnectorId id);

}
