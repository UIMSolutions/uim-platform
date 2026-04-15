/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.ports.repositories.data_processing_logs;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

interface DataProcessingLogRepository {
    bool exitstsById(DataProcessingLogId id);
    DataProcessingLog findById(DataProcessingLogId id);

    DataProcessingLog[] findByTenant(TenantId tenantId);
    DataProcessingLog[] findByDataSubject(DataSubjectId dataSubjectId);
    DataProcessingLog[] findByRequest(DataSubjectRequestId requestId);
    DataProcessingLog[] findByApplication(string applicationId);
    
    void save(DataProcessingLog entity);
    void remove(DataProcessingLogId id);
}
