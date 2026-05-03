/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.infrastructure.persistence.memory.personal_data_records;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class MemoryPersonalDataRecordRepository : TenantRepository!(PersonalDataRecord, PersonalDataRecordId), PersonalDataRecordRepository {
    
    // #region ByDataSubject
    size_t countByDataSubject(DataSubjectId dataSubjectId) {
        return findByDataSubject(dataSubjectId).length;
    }

    PersonalDataRecord[] filterByDataSubject(PersonalDataRecord[] records, DataSubjectId dataSubjectId, uint offset = 0, uint limit = 0) {
        return (limit == 0)
            ? records.filter!(v => v.dataSubjectId == dataSubjectId).skip(offset)
            .array : records.filter!(v => v.dataSubjectId == dataSubjectId)
            .skip(offset).take(limit).array;
    }

    PersonalDataRecord[] findByDataSubject(DataSubjectId dataSubjectId) {
        return filterByDataSubject(findAll(), dataSubjectId, 0, 0);
    }

    void removeByDataSubject(DataSubjectId dataSubjectId) {
        findByDataSubject(dataSubjectId).each!(v => remove(v));
    }
    // #endregion ByDataSubject

    // #region ByApplication
    size_t countByApplication(RegisteredApplicationId applicationId) {
        return findByApplication(applicationId).length;
    }

    PersonalDataRecord[] filterByApplication(PersonalDataRecord[] records, RegisteredApplicationId applicationId, uint offset = 0, uint limit = 0) {
        return (limit == 0)
            ? records.filter!(v => v.applicationId == applicationId).skip(offset)
            .array : records.filter!(v => v.applicationId == applicationId)
            .skip(offset).take(limit).array;
    }

    PersonalDataRecord[] findByApplication(RegisteredApplicationId applicationId) {
        return filterByApplication(findAll(), applicationId, 0, 0);
    }

    void removeByApplication(RegisteredApplicationId applicationId) {
        findByApplication(applicationId).each!(v => remove(v));
    }
    // #endregion ByApplication

    // #region ByDataSubjectAndApplication
    size_t countByDataSubjectAndApplication(DataSubjectId dataSubjectId, RegisteredApplicationId applicationId) {
        return findByDataSubjectAndApplication(dataSubjectId, applicationId).length;
    }

    PersonalDataRecord[] filterByDataSubjectAndApplication(PersonalDataRecord[] records, DataSubjectId dataSubjectId, RegisteredApplicationId applicationId, uint offset = 0, uint limit = 0) {
        return (limit == 0)
            ? records.filter!(v => v.dataSubjectId == dataSubjectId && v.applicationId == applicationId).skip(offset)
            .array
            : records.filter!(v => v.dataSubjectId == dataSubjectId && v.applicationId == applicationId).skip(offset)
            .take(limit).array;
    }

    PersonalDataRecord[] findByDataSubjectAndApplication(DataSubjectId dataSubjectId, RegisteredApplicationId applicationId) {
        return filterByDataSubjectAndApplication(findAll(), dataSubjectId, applicationId, 0, 0);
    }

    void removeByDataSubjectAndApplication(DataSubjectId dataSubjectId, RegisteredApplicationId applicationId) {
        findByDataSubjectAndApplication(dataSubjectId, applicationId).each!(v => remove(v));
    }
    // #endregion ByDataSubjectAndApplication

}
