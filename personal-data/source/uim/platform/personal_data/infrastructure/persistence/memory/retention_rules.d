/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.infrastructure.persistence.memory.retention_rules;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class MemoryRetentionRuleRepository : TenantRepository!(RetentionRule, RetentionRuleId), RetentionRuleRepository {

    size_t countByApplication(RegisteredApplicationId applicationId) {
        return findByApplication(applicationId).length;
    }
    RetentionRule[] findByApplication(RegisteredApplicationId applicationId) {
        import std.algorithm : canFind;
        RetentionRule[] result;
        foreach (v; findAll)
            if (v.applicationIds.canFind(applicationId)) result ~= v;
        return result;
    }
    void removeByApplication(RegisteredApplicationId applicationId) {
        findByApplication(applicationId).each!(v => store.remove(v));
    }

    size_t countByStatus(RetentionRuleStatus status) {
        return findByStatus(status).length;
    }
    RetentionRule[] findByStatus(RetentionRuleStatus status) {
        RetentionRule[] result;
        foreach (v; findAll)
            if (v.status == status) result ~= v;
        return result;
    }
    void removeByStatus(RetentionRuleStatus status) {
        findByStatus(status).each!(v => store.remove(v));
    }

}
