/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.usage_data.app.usecases.daily_usage_reports;

import uim.platform.usage_data;

// mixin(ShowModule!());
@safe:
/// Application service: daily usage report use cases.
class DailyUsageReportUseCases {
  private DailyUsageReportRepository repo;

  this(DailyUsageReportRepository repo) {
    this.repo = repo;
  }

  DailyUsageReportResponse createReport(CreateDailyUsageReportRequest req) {
    auto report = DailyUsageReport.create(req.accountId, req.subaccountId,
      req.reportYear, req.reportMonth, req.reportDay);
    repo.save(report);
    return DailyUsageReportResponse.fromEntity(report);
  }

  DailyUsageReportResponse getReport(TenantId tenantId, DailyUsageReportId id) {
    auto r = repo.find(tenantId, id);
    return DailyUsageReportResponse.fromEntity(r);
  }

  DailyUsageReportResponse[] listReports(TenantId tenantId) {
    DailyUsageReportResponse[] result;
    foreach (r; repo.find(tenantId))
      result ~= DailyUsageReportResponse.fromEntity(r);
    return result;
  }

  DailyUsageReportResponse[] listBySubaccount(TenantId tenantId, string subaccountId) {
    DailyUsageReportResponse[] result;
    foreach (r; repo.findBySubaccount(tenantId, subaccountId))
      result ~= DailyUsageReportResponse.fromEntity(r);
    return result;
  }

  DailyUsageReportResponse markReady(TenantId tenantId, DailyUsageReportId id) {
    auto r = repo.find(tenantId, id);
    if (r.isNull) return DailyUsageReportResponse.init;
    r.status = ReportStatus.ready;
    repo.save(r);
    return DailyUsageReportResponse.fromEntity(r);
  }

  CommandResult deleteReport(TenantId tenantId, DailyUsageReportId id) {
    auto r = repo.find(tenantId, id);
    if (r.isNull) return CommandResult(false, "", "Daily usage report not found");
    repo.remove(r);
    return CommandResult(true, r.id.value, "");
  }
}
