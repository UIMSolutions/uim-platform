/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.entities.data_processing_log;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

struct DataProcessingLog {
    mixin TenantEntity!DataProcessingLogId;
    
    LogEntryType entryType;
    LogSeverity severity;
    DataSubjectId dataSubjectId;
    string applicationId;
    string requestId;
    string operatorId;
    string action;
    string details;
    string affectedFields;
    string ipAddress;
    
    Json toJson() const {
        return entityToJson
            .set("entryType", entryType.to!string())
            .set("severity", severity.to!string())
            .set("dataSubjectId", dataSubjectId)
            .set("applicationId", applicationId)
            .set("requestId", requestId)
            .set("operatorId", operatorId)
            .set("action", action)
            .set("details", details)
            .set("affectedFields", affectedFields)
            .set("ipAddress", ipAddress);
    }
}
