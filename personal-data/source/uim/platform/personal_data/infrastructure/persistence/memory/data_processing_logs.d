/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.infrastructure.persistence.memory.data_processing_logs;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class MemoryDataProcessingLogRepository : TenantRepository!(DataProcessingLog, DataProcessingLogId), DataProcessingLogRepository {

    // #region ByDataSubject
    size_t countByDataSubject(DataSubjectId dataSubjectId) {
        return findByDataSubject(dataSubjectId).length;
    }
    DataProcessingLog[] findByDataSubject(DataSubjectId dataSubjectId) {
        DataProcessingLog[] result;
        foreach (v; findAll)
            if (v.dataSubjectId == dataSubjectId) result ~= v;
        return result;
    }
    void removeByDataSubject(DataSubjectId dataSubjectId) {
        findByDataSubject(dataSubjectId).each!(v => store.remove(v));
    }
    // #endregion ByDataSubject

    // #region ByRequest
    size_t countByRequest(DataSubjectRequestId requestId) {
        return findByRequest(requestId).length;
    }
    DataProcessingLog[] findByRequest(DataSubjectRequestId requestId) {
        DataProcessingLog[] result;
        foreach (v; findAll)
            if (v.requestId == requestId) result ~= v;
        return result;
    }
    void removeByRequest(DataSubjectRequestId requestId) {
        findByRequest(requestId).each!(v => store.remove(v));
    }
    // #endregion ByRequest

    // #region ByApplication
    size_t countByApplication(string applicationId) {
        return findByApplication(applicationId).length;
    }
    DataProcessingLog[] findByApplication(string applicationId) {
        DataProcessingLog[] result;
        foreach (v; findAll)
            if (v.applicationId == applicationId) result ~= v;
        return result;
    }
    void removeByApplication(string applicationId) {
        findByApplication(applicationId).each!(v => store.remove(v));
    }
    // #endregion ByApplication
}
