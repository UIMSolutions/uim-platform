/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.repositories.app_definitions;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

interface IAppDefinitionRepository : ITenantRepository!(AppDefinition, AppDefinitionId) {
    AppDefinition[] findByMobileApplication(TenantId tenantId, MobileApplicationId appId);
    AppDefinition[] findByStatus(TenantId tenantId, DefinitionStatus status);
    void removeByMobileApplication(TenantId tenantId, MobileApplicationId appId);
}
