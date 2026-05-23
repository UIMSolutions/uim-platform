/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.ports.repositories.data_processing_logs;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

interface DataProcessingLogRepository : ITenantRepository!(DataProcessingLog, DataProcessingLogId) {

    size_t countByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);
    DataProcessingLog[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);
    void removeByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);

    size_t countByRequest(TenantId tenantId, DataSubjectRequestId requestId);
    DataProcessingLog[] findByRequest(TenantId tenantId, DataSubjectRequestId requestId);
    void removeByRequest(TenantId tenantId, DataSubjectRequestId requestId);

    size_t countByApplication(TenantId tenantId, string applicationId);
    DataProcessingLog[] findByApplication(TenantId tenantId, string applicationId);
    void removeByApplication(TenantId tenantId, string applicationId);
    
}
