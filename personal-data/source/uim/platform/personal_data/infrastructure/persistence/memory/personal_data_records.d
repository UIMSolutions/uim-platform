/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.infrastructure.persistence.memory.personal_data_records;

import uim.platform.personal_data;

// mixin(ShowModule!());

@safe:

class MemoryPersonalDataRecordRepository : TentRepository!(PersonalDataRecord, PersonalDataRecordId), PersonalDataRecordRepository {
    
    // #region ByDataSubject
    size_t countByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId) {
        return findByDataSubject(tenantId, dataSubjectId).length;
    }

    PersonalDataRecord[] filterByDataSubject(PersonalDataRecord[] records, DataSubjectId dataSubjectId, size_t offset = 0, size_t limit = 0) {
        return (limit == 0)
            ? records.filter!(v => v.dataSubjectId == dataSubjectId).skip(offset)
            .array : records.filter!(v => v.dataSubjectId == dataSubjectId)
            .skip(offset).take(limit).array;
    }

    PersonalDataRecord[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId) {
        return filterByDataSubject(findByTenant(tenantId), dataSubjectId, 0, 0);
    }

    void removeByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId) {
        findByDataSubject(tenantId, dataSubjectId).each!(v => remove(v));
    }
    // #endregion ByDataSubject

    // #region ByApplication
    size_t countByApplication(TenantId tenantId, RegisteredApplicationId applicationId) {
        return findByApplication(tenantId, applicationId).length;
    }

    PersonalDataRecord[] filterByApplication(PersonalDataRecord[] records, RegisteredApplicationId applicationId, size_t offset = 0, size_t limit = 0) {
        return (limit == 0)
            ? records.filter!(v => v.applicationId == applicationId).skip(offset)
            .array : records.filter!(v => v.applicationId == applicationId)
            .skip(offset).take(limit).array;
    }

    PersonalDataRecord[] findByApplication(TenantId tenantId, RegisteredApplicationId applicationId) {
        return filterByApplication(findByTenant(tenantId), applicationId, 0, 0);
    }

    void removeByApplication(TenantId tenantId, RegisteredApplicationId applicationId) {
        findByApplication(tenantId, applicationId).each!(v => remove(v));
    }
    // #endregion ByApplication

    // #region ByDataSubjectAndApplication
    size_t countByDataSubjectAndApplication(TenantId tenantId, DataSubjectId dataSubjectId, RegisteredApplicationId applicationId) {
        return findByDataSubjectAndApplication(tenantId, dataSubjectId, applicationId).length;
    }

    PersonalDataRecord[] filterByDataSubjectAndApplication(TenantId tenantId, PersonalDataRecord[] records, DataSubjectId dataSubjectId, RegisteredApplicationId applicationId, size_t offset = 0, size_t limit = 0) {
        return (limit == 0)
            ? records.filter!(v => v.dataSubjectId == dataSubjectId && v.applicationId == applicationId).skip(offset)
            .array
            : records.filter!(v => v.dataSubjectId == dataSubjectId && v.applicationId == applicationId).skip(offset)
            .take(limit).array;
    }

    PersonalDataRecord[] findByDataSubjectAndApplication(TenantId tenantId, DataSubjectId dataSubjectId, RegisteredApplicationId applicationId) {
        return filterByDataSubjectAndApplication(findByTenant(tenantId), dataSubjectId, applicationId, 0, 0);
    }

    void removeByDataSubjectAndApplication(TenantId tenantId, DataSubjectId dataSubjectId, RegisteredApplicationId applicationId) {
        findByDataSubjectAndApplication(tenantId, dataSubjectId, applicationId).each!(v => remove(v));
    }
    // #endregion ByDataSubjectAndApplication

}
