/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.tests.usecases.app_definitions;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// Use case for managing app definitions.
interface IManageAppDefinitionsUseCase {
    
    AppDefinition[] listDefinitions(TenantId tenantId);
    AppDefinition[] listDefinitions(TenantId tenantId, MobileApplicationId appId);
    AppDefinition[] listByStatus(TenantId tenantId, DefinitionStatus status);
    AppDefinition getDefinition(TenantId tenantId, AppDefinitionId id);
    CommandResult createDefinition(AppDefinitionDTO dto);
    CommandResult updateDefinition(AppDefinitionDTO dto);
    CommandResult deleteDefinition(TenantId tenantId, AppDefinitionId id);

}