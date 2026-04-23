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

    size_t countByDataSubject(DataSubjectId dataSubjectId);
    DataProcessingLog[] findByDataSubject(DataSubjectId dataSubjectId);
    void removeByDataSubject(DataSubjectId dataSubjectId);

    size_t countByRequest(DataSubjectRequestId requestId);
    DataProcessingLog[] findByRequest(DataSubjectRequestId requestId);
    void removeByRequest(DataSubjectRequestId requestId);

    size_t countByApplication(string applicationId);
    DataProcessingLog[] findByApplication(string applicationId);
    void removeByApplication(string applicationId);
    
}
