/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.usecases.usage_reports;
// import uim.platform.mobile.domain.ports.repositories.usage_reports;
// import uim.platform.mobile.domain.entities.usage_report;
// import uim.platform.mobile.application.dto;


import uim.platform.mobile;

// mixin(Showmodule!());

@safe:
interface IManageUsageReportsUseCase { 

    CommandResult createUsageReport(CreateUsageReportRequest r);

    UsageReport getUsageReport(TenantId tenantId, UsageReportId id);

    UsageReport[] listUsageReports(TenantId tenantId);

    UsageReport[] listUsageReports(TenantId tenantId, MobileAppId appId);

    UsageReport[] listUsageReports(TenantId tenantId, DeviceRegistrationId deviceId);

    CommandResult deleteUsageReport(TenantId tenantId, UsageReportId id);

    size_t countByApp(TenantId tenantId, MobileAppId appId);

}
