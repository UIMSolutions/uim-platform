/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.infrastructure.persistence.memory.substitution_rules;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class MemorySubstitutionRuleRepository : TenantRepository!(SubstitutionRule, SubstitutionRuleId), SubstitutionRuleRepository {

    size_t countByUser(TenantId tenantId, string userId) {
        return findByUser(tenantId, userId).length;
    }

    SubstitutionRule[] findByUser(TenantId tenantId, string userId) {
        return findByTenant(tenantId).filter!(r => r.userId == userId).array;
    }

    void removeByUser(TenantId tenantId, string userId) {
        findByUser(tenantId, userId).each!(r => remove(r));
    }

    size_t countBySubstitute(TenantId tenantId, string substituteId) {
        return findBySubstitute(tenantId, substituteId).length;
    }

    SubstitutionRule[] findBySubstitute(TenantId tenantId, string substituteId) {
        return findByTenant(tenantId).filter!(r => r.substituteId == substituteId).array;
    }

    void removeBySubstitute(TenantId tenantId, string substituteId) {
        findBySubstitute(tenantId, substituteId).each!(r => remove(r));
    }

    size_t countByStatus(TenantId tenantId, SubstitutionStatus status) {
        return findByStatus(tenantId, status).length;
    }

    SubstitutionRule[] findByStatus(TenantId tenantId, SubstitutionStatus status) {
        return findByTenant(tenantId).filter!(r => r.status == status).array;
    }

    void removeByStatus(TenantId tenantId, SubstitutionStatus status) {
        findByStatus(tenantId, status).each!(r => remove(r));
    }

}
