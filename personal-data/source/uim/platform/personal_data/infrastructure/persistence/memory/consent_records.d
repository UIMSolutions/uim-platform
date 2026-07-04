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

    size_t countByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId) {
        return findByDataSubject(tenantId, dataSubjectId).length;
    }
    ConsentRecord[] filterByDataSubject(ConsentRecord[] records, DataSubjectId dataSubjectId) {
        return records.filter!(v => v.dataSubjectId == dataSubjectId).array;
    }   
    ConsentRecord[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId) {
        return filterByDataSubject(findByTenant(tenantId), dataSubjectId);
    }
    void removeByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId) {
        findByDataSubject(tenantId, dataSubjectId).each!(v => remove(v));
    }

    size_t countByPurpose(TenantId tenantId, ProcessingPurposeId purposeId) {
        return findByPurpose(tenantId, purposeId).length;
    
    }
    ConsentRecord[] filterByPurpose(ConsentRecord[] records, ProcessingPurposeId purposeId) {
        return records.filter!(v => v.purposeId == purposeId).array;
    }
    ConsentRecord[] findByPurpose(TenantId tenantId, ProcessingPurposeId purposeId) {
        return filterByPurpose(findByTenant(tenantId), purposeId);
    }
    void removeByPurpose(TenantId tenantId, ProcessingPurposeId purposeId) {
        findByPurpose(tenantId, purposeId).each!(v => remove(v));
    }

    bool existsByDataSubjectAndPurpose(TenantId tenantId, DataSubjectId dataSubjectId, ProcessingPurposeId purposeId) {
        foreach (v; findByTenant(tenantId))
            if (v.dataSubjectId == dataSubjectId && v.purposeId == purposeId) return true;
        return false;
    }
    ConsentRecord findByDataSubjectAndPurpose(TenantId tenantId, DataSubjectId dataSubjectId, ProcessingPurposeId purposeId) {
        foreach (v; findByDataSubject(tenantId, dataSubjectId))
            if (v.purposeId == purposeId) return v;
        return ConsentRecord.init;
    }
    void removeByDataSubjectAndPurpose(TenantId tenantId, DataSubjectId dataSubjectId, ProcessingPurposeId purposeId) {
        findByDataSubjectAndPurpose(tenantId, dataSubjectId, purposeId).each!(v => remove(v));
    }
}
