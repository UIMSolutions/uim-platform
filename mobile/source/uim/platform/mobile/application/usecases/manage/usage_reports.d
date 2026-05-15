/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.application.usecases.manage.usage_reports;
// import uim.platform.mobile.domain.ports.repositories.usage_reports;
// import uim.platform.mobile.domain.entities.usage_report;
// import uim.platform.mobile.domain.types;
// import uim.platform.mobile.application.dto;
// import std.uuid : randomUUID;

import uim.platform.mobile;

mixin(Showmodule!());

@safe:
class ManageUsageReportsUseCase { // TODO: UIMUseCase {
    private UsageReportRepository repo;

    this(UsageReportRepository repo) {
        this.repo = repo;
    }

    CommandResult createUsageReport(ReportUsageRequest r) {
        UsageReport usage;
        usage.initEntity(r.tenantId);

        usage.appId = r.appId;
        usage.deviceId = r.deviceId;
        usage.userId = r.userId;
        usage.eventType = r.eventType;
        usage.eventData = r.eventData;
        usage.sessionId = r.sessionId;
        usage.screenName = r.screenName;
        usage.duration = r.duration;
        usage.timestamp = r.timestamp > 0 ? r.timestamp : currentTimestamp();

        repo.save(usage);
        return CommandResult(true, usage.id.value, "");
    }

    UsageReport getUsageReport(TenantId tenantId, UsageReportId id) {
        return repo.findById(tenantId, id);
    }

    UsageReport[] listUsageReports(TenantId tenantId, MobileAppId appId) {
        return repo.findByApp(tenantId, appId);
    }

    UsageReport[] listUsageReports(TenantId tenantId, DeviceRegistrationId deviceId) {
        return repo.findByDevice(tenantId, deviceId);
    }

    CommandResult deleteUsageReport(TenantId tenantId, UsageReportId id) {
        auto report = repo.findById(tenantId, id);
        if (report.isNull)
            return CommandResult(false, "", "Usage report not found");

        repo.remove(report);
        return CommandResult(true, report.id.value, "");
    }

    size_t countByApp(TenantId tenantId, MobileAppId appId) {
        return repo.countByApp(tenantId, appId);
    }

}
