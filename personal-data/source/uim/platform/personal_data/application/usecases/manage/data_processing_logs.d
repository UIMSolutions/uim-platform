/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.application.usecases.manage.data_processing_logs;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class ManageDataProcessingLogsUseCase : UIMUseCase {
    private DataProcessingLogRepository repo;

    this(DataProcessingLogRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateDataProcessingLogRequest r) {
        if (r.id.length == 0) return CommandResult(false, "", "ID is required");

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
        return CommandResult(true, entry.id, "");
    }

    DataProcessingLog get_(DataProcessingLogId id) {
        return repo.findById(id);
    }

    DataProcessingLog[] list(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    DataProcessingLog[] listByDataSubject(DataSubjectId dataSubjectId) {
        return repo.findByDataSubject(dataSubjectId);
    }

    DataProcessingLog[] listByRequest(DataSubjectRequestId requestId) {
        return repo.findByRequest(requestId);
    }

    CommandResult remove(DataProcessingLogId id) {
        auto existing = repo.findById(id);
        if (existing.id.length == 0)
            return CommandResult(false, "", "Log entry not found");
        repo.remove(id);
        return CommandResult(true, id, "");
    }
}
