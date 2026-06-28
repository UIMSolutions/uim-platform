/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.presentation.rest.interfaces.app_definition;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

interface IAppDefinitionApi {
    @headerParam("tenantId", "X-Tenant-Id")
    AppDefinition[] listAppDefinitions(string tenantId);

    @headerParam("tenantId", "X-Tenant-Id")
    AppDefinition getAppDefinition(string tenantId, string definitionId);

    @headerParam("tenantId", "X-Tenant-Id")
    void createAppDefinition(string tenantId, AppDefinition definition);

    @headerParam("tenantId", "X-Tenant-Id")
    void updateAppDefinition(string tenantId, AppDefinition definition);

    @headerParam("tenantId", "X-Tenant-Id")
    void deleteAppDefinition(string tenantId, string definitionId);
}
