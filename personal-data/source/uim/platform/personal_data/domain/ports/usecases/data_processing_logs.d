/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.ports.usecases.data_processing_logs;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

interface IManageDataProcessingLogsUseCase {

    CommandResult createProcessingLog(CreateDataProcessingLogRequest r);
    bool hasProcessingLog(TenantId tenantId, DataProcessingLogId id);
    DataProcessingLog getProcessingLog(TenantId tenantId, DataProcessingLogId id);
    DataProcessingLog[] listProcessingLogs(TenantId tenantId);
    DataProcessingLog[] listProcessingLogs(TenantId tenantId, DataSubjectId dataSubjectId);
    DataProcessingLog[] listProcessingLogs(TenantId tenantId, DataSubjectRequestId requestId);
    CommandResult deleteProcessingLog(TenantId tenantId, DataProcessingLogId id);

}
