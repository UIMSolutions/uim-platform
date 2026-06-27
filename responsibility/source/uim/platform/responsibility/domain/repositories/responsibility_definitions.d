/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.domain.repositories.responsibility_definitions;

import uim.platform.responsibility;

// mixin(ShowModule!());

@safe:

interface ResponsibilityDefinitionRepository : ITenantRepository!(ResponsibilityDefinition, ResponsibilityDefinitionId) {
    ResponsibilityDefinition[] findByContext(TenantId tenantId, string contextId);
    ResponsibilityDefinition[] findByTeam(TenantId tenantId, string teamId);
    ResponsibilityDefinition[] findByRule(TenantId tenantId, string ruleId);
    ResponsibilityDefinition[] findByStatus(TenantId tenantId, DefinitionStatus status);
}
