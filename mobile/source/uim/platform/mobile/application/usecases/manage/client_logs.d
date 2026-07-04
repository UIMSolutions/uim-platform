/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.application.usecases.manage.client_logs;
// import uim.platform.mobile.domain.ports.repositories.client_logs;
// import uim.platform.mobile.domain.entities.client_log_entry;

// import uim.platform.mobile.application.dto;

import uim.platform.mobile;

// mixin(Showmodule!());

@safe:
class ManageClientLogsUseCase { // TODO: UIMUseCase {
    private ClientLogRepository repo;

    this(ClientLogRepository repo) {
        this.repo = repo;
    }

    CommandResult uploadLog(UploadClientLogRequest r) {
        auto entry = ClientLogEntry(r.tenantId);
        entry.appId = r.appId;
        entry.deviceId = r.deviceId;
        entry.userId = r.userId;
        entry.level = r.level.toLoggingLevel();
        entry.message = r.message;
        entry.stackTrace = r.stackTrace;
        // TODO: entry.context = r.context;
        entry.appVersion = r.appVersion;
        entry.osVersion = r.osVersion;
        entry.timestamp = r.timestamp > 0 ? r.timestamp : currentTimestamp();

        repo.save(entry);
        return CommandResult(true, entry.id.value, "");
    }

    ClientLogEntry getLog(TenantId tenantId, ClientLogEntryId id) {
        return repo.findById(tenantId, id);
    }

    ClientLogEntry[] listLogs(TenantId tenantId, MobileAppId appId) {
        return repo.findByApp(tenantId, appId);
    }

    ClientLogEntry[] listLogs(TenantId tenantId, DeviceRegistrationId deviceId) {
        return repo.findByDevice(tenantId, deviceId);
    }

    ClientLogEntry[] listLogs(TenantId tenantId, MobileAppId appId, string level) {
        return repo.findByLevel(tenantId, appId, level.toLoggingLevel());
    }

    CommandResult deleteLog(TenantId tenantId, ClientLogEntryId id) {
        auto entry = repo.findById(tenantId, id);
        if (entry.isNull)
            return CommandResult(false, "", "Client log entry not found");

        repo.remove(entry);
        return CommandResult(true, entry.id.value, "");
    }

    size_t countLogs(TenantId tenantId, MobileAppId appId) {
        return repo.countByApp(tenantId, appId);
    }

}
