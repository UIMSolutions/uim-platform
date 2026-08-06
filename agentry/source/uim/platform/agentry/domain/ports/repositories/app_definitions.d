/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.ports.repositories.app_definitions;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// Interface for managing application definitions in the repository.
interface IAppDefinitionRepository : ITenantRepository!(AppDefinition, AppDefinitionId) {

    size_t countByMobileApplication(TenantId tenantId, MobileApplicationId appId);
    AppDefinition[] findByMobileApplication(TenantId tenantId, MobileApplicationId appId);
    void removeByMobileApplication(TenantId tenantId, MobileApplicationId appId);

    size_t countByStatus(TenantId tenantId, DefinitionStatus status);
    AppDefinition[] findByStatus(TenantId tenantId, DefinitionStatus status);
    void removeByStatus(TenantId tenantId, DefinitionStatus status);

}
