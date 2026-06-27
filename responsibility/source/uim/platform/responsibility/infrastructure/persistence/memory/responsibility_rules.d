/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.infrastructure.persistence.memory.responsibility_rules;

import uim.platform.responsibility;

// mixin(ShowModule!());

@safe:

class MemoryResponsibilityRuleRepository
    : TenantRepository!(ResponsibilityRule, ResponsibilityRuleId),
      ResponsibilityRuleRepository {

    ResponsibilityRule[] findByStatus(TenantId tenantId, RuleStatus status) {
        return findByTenant(tenantId).filter!(r => r.status == status).array;
    }

    ResponsibilityRule[] findByType(TenantId tenantId, RuleType ruleType) {
        return findByTenant(tenantId).filter!(r => r.ruleType == ruleType).array;
    }

    ResponsibilityRule[] findByContext(TenantId tenantId, string contextId) {
        return findByTenant(tenantId).filter!(r => r.contextId == contextId).array;
    }
}
