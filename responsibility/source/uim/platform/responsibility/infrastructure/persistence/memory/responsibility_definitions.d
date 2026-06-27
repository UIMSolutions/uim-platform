/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.infrastructure.persistence.memory.responsibility_definitions;

import uim.platform.responsibility;

// mixin(ShowModule!());

@safe:

class MemoryResponsibilityDefinitionRepository
    : TentRepository!(ResponsibilityDefinition, ResponsibilityDefinitionId),
      ResponsibilityDefinitionRepository {

    ResponsibilityDefinition[] findByContext(TenantId tenantId, string contextId) {
        return findByTenant(tenantId).filter!(d => d.contextId == contextId).array;
    }

    ResponsibilityDefinition[] findByTeam(TenantId tenantId, string teamId) {
        return findByTenant(tenantId).filter!(d => d.teamId == teamId).array;
    }

    ResponsibilityDefinition[] findByRule(TenantId tenantId, string ruleId) {
        return findByTenant(tenantId).filter!(d => d.ruleId == ruleId).array;
    }

    ResponsibilityDefinition[] findByStatus(TenantId tenantId, DefinitionStatus status) {
        return findByTenant(tenantId).filter!(d => d.status == status).array;
    }
}
