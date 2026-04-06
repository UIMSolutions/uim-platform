/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.asset_strategy_performance.infrastructure.persistence.memory.assessments;

import uim.platform.asset_strategy_performance;

mixin(ShowModule!());

@safe:

class MemoryAssessmentRepository : AssessmentRepository {
    private Assessment[] store;

    Assessment[] findAll() { return store; }

    Assessment* findById(AssessmentId id) {
        foreach (ref a; store)
            if (a.id == id) return &a;
        return null;
    }

    Assessment[] findByTenant(TenantId tenantId) {
        Assessment[] result;
        foreach (ref a; store)
            if (a.tenantId == tenantId) result ~= a;
        return result;
    }

    Assessment[] findByEquipment(EquipmentId equipmentId) {
        Assessment[] result;
        foreach (ref a; store)
            if (a.equipmentId == equipmentId) result ~= a;
        return result;
    }

    Assessment[] findByType(AssessmentType assessmentType) {
        Assessment[] result;
        foreach (ref a; store)
            if (a.assessmentType == assessmentType) result ~= a;
        return result;
    }

    Assessment[] findByStatus(AssessmentStatus status) {
        Assessment[] result;
        foreach (ref a; store)
            if (a.status == status) result ~= a;
        return result;
    }

    void save(Assessment assessment) { store ~= assessment; }

    void update(Assessment assessment) {
        foreach (ref a; store)
            if (a.id == assessment.id) { a = assessment; return; }
    }

    void remove(AssessmentId id) {
        import std.algorithm : remove;
        store = store.remove!(a => a.id == id);
    }
}
