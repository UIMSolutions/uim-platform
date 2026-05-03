/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.infrastructure.persistence.memory.consent_records;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class MemoryConsentRecordRepository : TenantRepository!(ConsentRecord, ConsentRecordId), ConsentRecordRepository {

    size_t countByDataSubject(DataSubjectId dataSubjectId) {
        return findByDataSubject(dataSubjectId).length;
    }
    ConsentRecord[] findByDataSubject(DataSubjectId dataSubjectId) {
        ConsentRecord[] result;
        foreach (v; findAll)
            if (v.dataSubjectId == dataSubjectId) result ~= v;
        return result;
    }
    void removeByDataSubject(DataSubjectId dataSubjectId) {
        findByDataSubject(dataSubjectId).each!(v => remove(v));
    }

    size_t countByPurpose(ProcessingPurposeId purposeId) {
        return findByPurpose(purposeId).length;
    }
    ConsentRecord[] findByPurpose(ProcessingPurposeId purposeId) {
        ConsentRecord[] result;
        foreach (v; findAll)
            if (v.purposeId == purposeId) result ~= v;
        return result;
    }
    void removeByPurpose(ProcessingPurposeId purposeId) {
        findByPurpose(purposeId).each!(v => remove(v));
    }

    bool existsByDataSubjectAndPurpose(DataSubjectId dataSubjectId, ProcessingPurposeId purposeId) {
        foreach (v; findAll)
            if (v.dataSubjectId == dataSubjectId && v.purposeId == purposeId) return true;
        return false;
    }
    ConsentRecord findByDataSubjectAndPurpose(DataSubjectId dataSubjectId, ProcessingPurposeId purposeId) {
        foreach (v; findAll)
            if (v.dataSubjectId == dataSubjectId && v.purposeId == purposeId) return v;
        return ConsentRecord.init;
    }
    void removeByDataSubjectAndPurpose(DataSubjectId dataSubjectId, ProcessingPurposeId purposeId) {
        findByDataSubjectAndPurpose(dataSubjectId, purposeId).each!(v => remove(v));
    }
}
