/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.application.usecases.manage.data_processing_logs;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class ManageDataProcessingLogsUseCase { // TODO: UIMUseCase {
    private DataProcessingLogRepository repo;

    this(DataProcessingLogRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateDataProcessingLogRequest r) {
        if (r.isNull) return CommandResult(false, "", "ID is required");

        import std.conv : to;

        DataProcessingLog entry;
        entry.id = r.id;
        entry.tenantId = r.tenantId;
        entry.entryType = r.entryType.length > 0 ? r.entryType.to!LogEntryType : LogEntryType.access;
        entry.severity = r.severity.length > 0 ? r.severity.to!LogSeverity : LogSeverity.info;
        entry.dataSubjectId = r.dataSubjectId;
        entry.applicationId = r.applicationId;
        entry.requestId = r.requestId;
        entry.operatorId = r.operatorId;
        entry.action = r.action;
        entry.details = r.details;
        entry.affectedFields = r.affectedFields;
        entry.ipAddress = r.ipAddress;
        entry.createdAt = clockTime();

        repo.save(entry);
        return CommandResult(true, entry.id.value, "");
    }

    bool hasById(DataProcessingLogId id) {
        return repo.existsById(id);
    }

    bool hasById(string id) {
        return hasById(DataProcessingLogId(id));
    }

    DataProcessingLog getById(DataProcessingLogId id) {
        return repo.findById(id);
    }

    DataProcessingLog getById(string id) {
        return getById(DataProcessingLogId(id));
    }

    DataProcessingLog[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    DataProcessingLog[] listByTenant(TenantId tenantId) {
        return listByTenant(TenantId(tenantId));
    }

    DataProcessingLog[] listByDataSubject(DataSubjectId dataSubjectId) {
        return repo.findByDataSubject(dataSubjectId);
    }

    DataProcessingLog[] listByDataSubject(string dataSubjectId) {
        return listByDataSubject(DataSubjectId(dataSubjectId));
    }

    DataProcessingLog[] listByRequest(DataSubjectRequestId requestId) {
        return repo.findByRequest(requestId);
    }

    DataProcessingLog[] listByRequest(string requestId) {
        return listByRequest(DataSubjectRequestId(requestId));
    }

    CommandResult removeById(DataProcessingLogId id) {
        auto existing = repo.findById(id);
        if (existing.isNull)
            return CommandResult(false, "", "Log entry not found");
        repo.removeById(id);
        return CommandResult(true, id.value, "");
    }

    CommandResult removeById(string id) {
        return removeById(DataProcessingLogId(id));
    }
}
