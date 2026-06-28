/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.infrastructure.persistence.memory.data_processing_logs;

import uim.platform.personal_data;

// mixin(ShowModule!());

@safe:

class MemoryDataProcessingLogRepository : TenantRepository!(DataProcessingLog, DataProcessingLogId), DataProcessingLogRepository {

    // #region ByDataSubject
    size_t countByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId) {
        return findByDataSubject(tenantId, dataSubjectId).length;
    }
    DataProcessingLog[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId) {
        DataProcessingLog[] result;
        foreach (v; find(tenantId))
            if (v.dataSubjectId == dataSubjectId) result ~= v;
        return result;
    }
    void removeByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId) {
        findByDataSubject(tenantId, dataSubjectId).each!(v => store.remove(v));
    }
    // #endregion ByDataSubject

    // #region ByRequest
    size_t countByRequest(TenantId tenantId, DataSubjectRequestId requestId) {
        return findByRequest(tenantId, requestId).length;
    }
    DataProcessingLog[] findByRequest(TenantId tenantId, DataSubjectRequestId requestId) {
        DataProcessingLog[] result;
        foreach (v; find(tenantId))
            if (v.requestId == requestId) result ~= v;
        return result;
    }
    void removeByRequest(TenantId tenantId, DataSubjectRequestId requestId) {
        findByRequest(tenantId, requestId).each!(v => store.remove(v));
    }
    // #endregion ByRequest

    // #region ByApplication
    size_t countByApplication(TenantId tenantId, string applicationId) {
        return findByApplication(tenantId, applicationId).length;
    }
    DataProcessingLog[] findByApplication(TenantId tenantId, string applicationId) {
        DataProcessingLog[] result;
        foreach (v; find(tenantId))
            if (v.applicationId == applicationId) result ~= v;
        return result;
    }
    void removeByApplication(TenantId tenantId, string applicationId) {
        findByApplication(tenantId, applicationId).each!(v => store.remove(v));
    }
    // #endregion ByApplication
}
