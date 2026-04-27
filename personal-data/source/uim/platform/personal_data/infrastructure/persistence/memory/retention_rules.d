/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.infrastructure.persistence.memory.retention_rules;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class MemoryRetentionRuleRepository :TenantRepository!(RetentionRule, RetentionRuleId), RetentionRuleRepository {
    private RetentionRule[RetentionRuleId] store;

    RetentionRule findById(RetentionRuleId id) {
        if (auto p = id in store) return *p;
        return RetentionRule.init;
    }

    RetentionRule[] findByTenant(TenantId tenantId) {
        RetentionRule[] result;
        foreach (v; findAll)
            if (v.tenantId == tenantId) result ~= v;
        return result;
    }

    RetentionRule[] findByApplication(RegisteredApplicationId applicationId) {
        import std.algorithm : canFind;
        RetentionRule[] result;
        foreach (v; findAll)
            if (v.applicationIds.canFind(applicationId)) result ~= v;
        return result;
    }

    RetentionRule[] findByStatus(RetentionRuleStatus status) {
        RetentionRule[] result;
        foreach (v; findAll)
            if (v.status == status) result ~= v;
        return result;
    }

    void save(RetentionRule entity) { store[entity.id] = entity; }
    void update(RetentionRule entity) { store[entity.id] = entity; }
    void remove(RetentionRuleId id) { store.remove(id); }
}
