/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.application.usecases.manage.usage_reports;

import uim.platform.mobile.domain.ports.repositories.usage_reports;
import uim.platform.mobile.domain.entities.usage_report;
import uim.platform.mobile.domain.types;
import uim.platform.mobile.application.dto;
import std.uuid : randomUUID;
import std.conv : to;

class ManageUsageReportsUseCase : UIMUseCase {
    private UsageReportRepository repo;

    this(UsageReportRepository repo) {
        this.repo = repo;
    }

    CommandResult report(ReportUsageRequest r) {
        UsageReport usage;
        usage.id = randomUUID();
        usage.tenantId = r.tenantId;
        usage.appId = r.appId;
        usage.deviceId = r.deviceId;
        usage.userId = r.userId;
        usage.eventType = r.eventType;
        usage.eventData = r.eventData;
        usage.sessionId = r.sessionId;
        usage.screenName = r.screenName;
        usage.duration = r.duration;
        usage.timestamp = r.timestamp > 0 ? r.timestamp : currentTimestamp();
        usage.createdAt = currentTimestamp();
        repo.save(usage);
        return CommandResult(true, usage.id, "");
    }

    UsageReport get_(UsageReportId id) {
        return repo.findById(id);
    }

    UsageReport[] listByApp(MobileAppId appId) {
        return repo.findByApp(appId);
    }

    UsageReport[] listByDevice(DeviceRegistrationId deviceId) {
        return repo.findByDevice(deviceId);
    }

    void remove(UsageReportId id) {
        repo.remove(id);
    }

    size_t countByApp(MobileAppId appId) {
        return repo.countByApp(appId);
    }

    private static long currentTimestamp() {
        import std.datetime.systime : Clock;
        return Clock.currStdTime();
    }
}
