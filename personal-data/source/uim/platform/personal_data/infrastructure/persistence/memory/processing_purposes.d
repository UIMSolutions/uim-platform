/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.infrastructure.persistence.memory.processing_purposes;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class MemoryProcessingPurposeRepository : ProcessingPurposeRepository {
    private ProcessingPurpose[ProcessingPurposeId] store;

    ProcessingPurpose findById(ProcessingPurposeId id) {
        if (auto p = id in store) return *p;
        return ProcessingPurpose.init;
    }

    ProcessingPurpose[] findByTenant(TenantId tenantId) {
        ProcessingPurpose[] result;
        foreach (v; findAll)
            if (v.tenantId == tenantId) result ~= v;
        return result;
    }

    ProcessingPurpose[] findByLegalBasis(LegalBasis basis) {
        ProcessingPurpose[] result;
        foreach (v; findAll)
            if (v.legalBasis == basis) result ~= v;
        return result;
    }

    ProcessingPurpose[] findByApplication(RegisteredApplicationId applicationId) {
        import std.algorithm : canFind;
        ProcessingPurpose[] result;
        foreach (v; findAll)
            if (v.applicationIds.canFind(applicationId)) result ~= v;
        return result;
    }

    void save(ProcessingPurpose entity) { store[entity.id] = entity; }
    void update(ProcessingPurpose entity) { store[entity.id] = entity; }
    void remove(ProcessingPurposeId id) { store.remove(id); }
}
