/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.infrastructure.persistence.memory.substitution_rules;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class MemorySubstitutionRuleRepository :TenantRepository!(SubstitutionRule, SubstitutionRuleId), SubstitutionRuleRepository {
    private SubstitutionRule[][string] store;

    SubstitutionRule findById(string tenantId, string id) {
        if (auto arr = tenantId in store)
            foreach (r; *arr)
                if (r.id == id) return r;
        return SubstitutionRule.init;
    }

    SubstitutionRule[] findByTenant(string tenantId) {
        if (auto arr = tenantId in store) return *arr;
        return [];
    }

    SubstitutionRule[] findByUser(string tenantId, string userId) {
        SubstitutionRule[] result;
        if (auto arr = tenantId in store)
            foreach (r; *arr)
                if (r.userId == userId) result ~= r;
        return result;
    }

    SubstitutionRule[] findBySubstitute(string tenantId, string substituteId) {
        SubstitutionRule[] result;
        if (auto arr = tenantId in store)
            foreach (r; *arr)
                if (r.substituteId == substituteId) result ~= r;
        return result;
    }

    SubstitutionRule[] findByStatus(string tenantId, SubstitutionStatus status) {
        SubstitutionRule[] result;
        if (auto arr = tenantId in store)
            foreach (r; *arr)
                if (r.status == status) result ~= r;
        return result;
    }

    void save(string tenantId, SubstitutionRule entity) {
        store[tenantId] ~= entity;
    }

    void update(string tenantId, SubstitutionRule entity) {
        if (auto arr = tenantId in store)
            foreach (r; *arr)
                if (r.id == entity.id) { r = entity; return; }
    }

    void remove(string tenantId, string id) {
        if (auto arr = tenantId in store) {
            SubstitutionRule[] filtered;
            foreach (r; *arr)
                if (r.id != id) filtered ~= r;
            store[tenantId] = filtered;
        }
    }
}
