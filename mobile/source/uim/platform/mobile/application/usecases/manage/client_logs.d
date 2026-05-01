/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.application.usecases.manage.client_logs;

import uim.platform.mobile.domain.ports.repositories.client_logs;
import uim.platform.mobile.domain.entities.client_log_entry;
import uim.platform.mobile.domain.types;
import uim.platform.mobile.application.dto;
import std.uuid : randomUUID;
import std.conv : to;

class ManageClientLogsUseCase { // TODO: UIMUseCase {
    private ClientLogRepository repo;

    this(ClientLogRepository repo) {
        this.repo = repo;
    }

    CommandResult upload(UploadClientLogRequest r) {
        ClientLogEntry entry;
        entry.id = randomUUID();
        entry.tenantId = r.tenantId;
        entry.appId = r.appId;
        entry.deviceId = r.deviceId;
        entry.userId = r.userId;
        entry.level = parseLogLevel(r.level);
        entry.message = r.message;
        entry.stackTrace = r.stackTrace;
        entry.context = r.context;
        entry.appVersion = r.appVersion;
        entry.osVersion = r.osVersion;
        entry.timestamp = r.timestamp > 0 ? r.timestamp : currentTimestamp();
        entry.createdAt = currentTimestamp();
        repo.save(entry);
        return CommandResult(true, entry.id, "");
    }

    ClientLogEntry get_(ClientLogEntryId id) {
        return repo.findById(id);
    }

    ClientLogEntry[] listByApp(MobileAppId appId) {
        return repo.findByApp(appId);
    }

    ClientLogEntry[] listByDevice(DeviceRegistrationId deviceId) {
        return repo.findByDevice(deviceId);
    }

    ClientLogEntry[] listByLevel(MobileAppId appId, string level) {
        return repo.findByLevel(appId, parseLogLevel(level));
    }

    void remove(ClientLogEntryId id) {
        repo.removeById(id);
    }

    size_t countByApp(MobileAppId appId) {
        return repo.countByApp(appId);
    }

    private static LogLevel parseLogLevel(string s) {
        switch (s) {
            case "debug": return LogLevel.debug_;
            case "info": return LogLevel.info;
            case "warn": return LogLevel.warn;
            case "error": return LogLevel.error;
            case "fatal": return LogLevel.fatal;
            default: return LogLevel.info;
        }
    }

    private static long currentTimestamp() {
        import std.datetime.systime : Clock;
        return Clock.currStdTime();
    }
}
