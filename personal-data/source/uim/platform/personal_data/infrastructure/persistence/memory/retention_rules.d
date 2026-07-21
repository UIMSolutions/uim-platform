/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.infrastructure.persistence.repositories.retention_rules;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class MemoryRetentionRuleRepository : TenantRepository!(RetentionRule, RetentionRuleId), RetentionRuleRepository {

    size_t countByApplication(TenantId tenantId, RegisteredApplicationId applicationId) {
        return findByApplication(tenantId, applicationId).length;
    }
    RetentionRule[] filterByApplication(RetentionRule[] rules, RegisteredApplicationId applicationId) {
        return rules.filter!(v => v.applicationIds.canFind(applicationId)).array;
    }   
    RetentionRule[] findByApplication(TenantId tenantId, RegisteredApplicationId applicationId) {
        import std.algorithm : canFind;
        RetentionRule[] result;
        foreach (v; findByTenant(tenantId))
            if (v.applicationIds.canFind(applicationId)) result ~= v;
        return result;
    }
    void removeByApplication(TenantId tenantId, RegisteredApplicationId applicationId) {
        findByApplication(tenantId, applicationId).each!(v => store.remove(v));
    }

    size_t countByStatus(TenantId tenantId, RetentionRuleStatus status) {
        return findByStatus(tenantId, status).length;
    }
    RetentionRule[] filterByStatus(RetentionRule[] rules, RetentionRuleStatus status) {
        return rules.filter!(v => v.status == status).array;
    }
    RetentionRule[] findByStatus(TenantId tenantId, RetentionRuleStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }
    void removeByStatus(TenantId tenantId, RetentionRuleStatus status) {
        findByStatus(tenantId,status).each!(v => store.remove(v));
    }

}
