/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.usage_data.app.usecases.monthly_usage_reports;

import uim.platform.usage_data;
mixin(ShowModule!());
@safe:
/// Application service: monthly usage report use cases.
class MonthlyUsageReportUseCases {
  private MonthlyUsageReportRepository repo;

  this(MonthlyUsageReportRepository repo) {
    this.repo = repo;
  }

  MonthlyUsageReportResponse createReport(CreateMonthlyUsageReportRequest req) {
    auto report = MonthlyUsageReport.create(req.accountId,
      req.reportingYear, req.reportingMonth);
    repo.save(report);
    return MonthlyUsageReportResponse.fromEntity(report);
  }

  MonthlyUsageReportResponse getReport(TenantId tenantId, MonthlyUsageReportId id) {
    auto r = repo.findById(tenantId, id);
    return MonthlyUsageReportResponse.fromEntity(r);
  }

  MonthlyUsageReportResponse[] listReports(TenantId tenantId) {
    MonthlyUsageReportResponse[] result;
    foreach (r; repo.findByTenant(tenantId))
      result ~= MonthlyUsageReportResponse.fromEntity(r);
    return result;
  }

  MonthlyUsageReportResponse[] listByGlobalAccount(TenantId tenantId, string globalAccountId) {
    MonthlyUsageReportResponse[] result;
    foreach (r; repo.findByGlobalAccount(tenantId, globalAccountId))
      result ~= MonthlyUsageReportResponse.fromEntity(r);
    return result;
  }

  MonthlyUsageReportResponse markReady(TenantId tenantId, MonthlyUsageReportId id) {
    auto r = repo.findById(tenantId, id);
    if (r.isNull) return MonthlyUsageReportResponse.init;
    r.status = ReportStatus.ready;
    repo.save(r);
    return MonthlyUsageReportResponse.fromEntity(r);
  }

  CommandResult deleteReport(TenantId tenantId, MonthlyUsageReportId id) {
    auto r = repo.findById(tenantId, id);
    if (r.isNull) return CommandResult(false, "", "Monthly usage report not found");
    repo.remove(r);
    return CommandResult(true, r.id.value, "");
  }
}
