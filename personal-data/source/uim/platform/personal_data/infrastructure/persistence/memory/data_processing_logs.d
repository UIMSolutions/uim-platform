/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.infrastructure.persistence.memory.data_processing_logs;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class MemoryDataProcessingLogRepository : DataProcessingLogRepository {
    private DataProcessingLog[DataProcessingLogId] store;

    DataProcessingLog findById(DataProcessingLogId id) {
        if (auto p = id in store) return *p;
        return DataProcessingLog.init;
    }

    DataProcessingLog[] findByTenant(TenantId tenantId) {
        DataProcessingLog[] result;
        foreach (v; findAll)
            if (v.tenantId == tenantId) result ~= v;
        return result;
    }

    DataProcessingLog[] findByDataSubject(DataSubjectId dataSubjectId) {
        DataProcessingLog[] result;
        foreach (v; findAll)
            if (v.dataSubjectId == dataSubjectId) result ~= v;
        return result;
    }

    DataProcessingLog[] findByRequest(DataSubjectRequestId requestId) {
        DataProcessingLog[] result;
        foreach (v; findAll)
            if (v.requestId == requestId) result ~= v;
        return result;
    }

    DataProcessingLog[] findByApplication(string applicationId) {
        DataProcessingLog[] result;
        foreach (v; findAll)
            if (v.applicationId == applicationId) result ~= v;
        return result;
    }

    void save(DataProcessingLog entity) { store[entity.id] = entity; }
    void remove(DataProcessingLogId id) { store.remove(id); }
}
