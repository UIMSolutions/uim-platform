/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.infrastructure.persistence.memory.personal_data_records;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class MemoryPersonalDataRecordRepository :TenantRepository!(PersonalDataRecord, PersonalDataRecordId), PersonalDataRecordRepository {
    private PersonalDataRecord[PersonalDataRecordId] store;

    PersonalDataRecord findById(PersonalDataRecordId id) {
        if (auto p = id in store) return *p;
        return PersonalDataRecord.init;
    }

    PersonalDataRecord[] findByTenant(TenantId tenantId) {
        PersonalDataRecord[] result;
        foreach (v; findAll)
            if (v.tenantId == tenantId) result ~= v;
        return result;
    }

    PersonalDataRecord[] findByDataSubject(DataSubjectId dataSubjectId) {
        PersonalDataRecord[] result;
        foreach (v; findAll)
            if (v.dataSubjectId == dataSubjectId) result ~= v;
        return result;
    }

    PersonalDataRecord[] findByApplication(RegisteredApplicationId applicationId) {
        PersonalDataRecord[] result;
        foreach (v; findAll)
            if (v.applicationId == applicationId) result ~= v;
        return result;
    }

    PersonalDataRecord[] findByDataSubjectAndApplication(DataSubjectId dataSubjectId, RegisteredApplicationId applicationId) {
        PersonalDataRecord[] result;
        foreach (v; findAll)
            if (v.dataSubjectId == dataSubjectId && v.applicationId == applicationId) result ~= v;
        return result;
    }

    void save(PersonalDataRecord entity) { store[entity.id] = entity; }
    void update(PersonalDataRecord entity) { store[entity.id] = entity; }
    void remove(PersonalDataRecordId id) { store.remove(id); }
}
