/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.infrastructure.persistence.memory.consent_records;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class MemoryConsentRecordRepository : ConsentRecordRepository {
    private ConsentRecord[ConsentRecordId] store;

    ConsentRecord findById(ConsentRecordId id) {
        if (auto p = id in store) return *p;
        return ConsentRecord.init;
    }

    ConsentRecord[] findByTenant(TenantId tenantId) {
        ConsentRecord[] result;
        foreach (v; findAll)
            if (v.tenantId == tenantId) result ~= v;
        return result;
    }

    ConsentRecord[] findByDataSubject(DataSubjectId dataSubjectId) {
        ConsentRecord[] result;
        foreach (v; findAll)
            if (v.dataSubjectId == dataSubjectId) result ~= v;
        return result;
    }

    ConsentRecord[] findByPurpose(ProcessingPurposeId purposeId) {
        ConsentRecord[] result;
        foreach (v; findAll)
            if (v.purposeId == purposeId) result ~= v;
        return result;
    }

    ConsentRecord findByDataSubjectAndPurpose(DataSubjectId dataSubjectId, ProcessingPurposeId purposeId) {
        foreach (v; findAll)
            if (v.dataSubjectId == dataSubjectId && v.purposeId == purposeId) return v;
        return ConsentRecord.init;
    }

    void save(ConsentRecord entity) { store[entity.id] = entity; }
    void update(ConsentRecord entity) { store[entity.id] = entity; }
    void remove(ConsentRecordId id) { store.remove(id); }
}
