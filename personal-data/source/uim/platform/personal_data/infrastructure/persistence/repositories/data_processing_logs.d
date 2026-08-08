/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.infrastructure.persistence.repositories.data_processing_logs;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class DataProcessingLogRepository : TenantRepository!(DataProcessingLog, DataProcessingLogId), IDataProcessingLogRepository {

    // #region ByDataSubject
    size_t countByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId) {
        return findByDataSubject(tenantId, dataSubjectId).length;
    }

    DataProcessingLog[] filterByDataSubject(DataProcessingLog[] logs, DataSubjectId dataSubjectId) {
        return logs.filter!(v => v.dataSubjectId == dataSubjectId).array;
    }

    DataProcessingLog[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId) {
        return filterByDataSubject(findByTenant(tenantId), dataSubjectId);
    }

    void removeByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId) {
        findByDataSubject(tenantId, dataSubjectId).each!(v => remove(v));
    }
    // #endregion ByDataSubject

    // #region ByRequest
    size_t countByRequest(TenantId tenantId, DataSubjectRequestId requestId) {
        return findByRequest(tenantId, requestId).length;
    }

    DataProcessingLog[] filterByRequest(DataProcessingLog[] logs, DataSubjectRequestId requestId) {
        return logs.filter!(v => v.id.value == requestId.value).array;
    }

    DataProcessingLog[] findByRequest(TenantId tenantId, DataSubjectRequestId requestId) {
        return filterByRequest(findByTenant(tenantId), requestId);
    }

    void removeByRequest(TenantId tenantId, DataSubjectRequestId requestId) {
        findByRequest(tenantId, requestId).each!(v => remove(v));
    }
    // #endregion ByRequest

    // #region ByApplication
    size_t countByApplication(TenantId tenantId, string applicationId) {
        return findByApplication(tenantId, applicationId).length;
    }

    DataProcessingLog[] filterByApplication(DataProcessingLog[] logs, string applicationId) {
        return logs.filter!(v => v.applicationId == applicationId).array;
    }

    DataProcessingLog[] findByApplication(TenantId tenantId, string applicationId) {
        return filterByApplication(findByTenant(tenantId), applicationId);
    }
    void removeByApplication(TenantId tenantId, string applicationId) {
        findByApplication(tenantId, applicationId).each!(v => remove(v));
    }
    // #endregion ByApplication
}
