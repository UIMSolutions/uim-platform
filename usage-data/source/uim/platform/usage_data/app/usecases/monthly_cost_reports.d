/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.usage_data.app.usecases.monthly_cost_reports;

import uim.platform.usage_data;

mixin(ShowModule!());
@safe:
/// Application service: monthly cost report use cases.
class MonthlyCostReportUseCases {
  protected IMonthlyCostReportRepository repo;

  this(IMonthlyCostReportRepository repo) {
    this.repo = repo;
  }

  MonthlyCostReportResponse createReport(CreateMonthlyCostReportRequest req) {
    auto report = MonthlyCostReport.create(req.globalAccountId, req.subaccountId,
      req.reportingYear, req.reportingMonth, req.currency);
    repo.save(report);
    return MonthlyCostReportResponse.fromEntity(report);
  }

  MonthlyCostReportResponse getReport(TenantId tenantId, MonthlyCostReportId id) {
    auto r = repo.findById(tenantId, id);
    return MonthlyCostReportResponse.fromEntity(r);
  }

  MonthlyCostReportResponse[] listReports(TenantId tenantId) {
    MonthlyCostReportResponse[] result;
    foreach (r; repo.findByTenant(tenantId))
      result ~= MonthlyCostReportResponse.fromEntity(r);
    return result;
  }

  MonthlyCostReportResponse[] listBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    MonthlyCostReportResponse[] result;
    foreach (r; repo.findBySubaccount(tenantId, subaccountId))
      result ~= MonthlyCostReportResponse.fromEntity(r);
    return result;
  }

  MonthlyCostReportResponse markReady(TenantId tenantId, MonthlyCostReportId id) {
    auto r = repo.findById(tenantId, id);
    if (r.isNull) return MonthlyCostReportResponse.init;
    r.status = ReportStatus.ready;
    repo.save(r);
    return MonthlyCostReportResponse.fromEntity(r);
  }

  UsecaseResult deleteReport(TenantId tenantId, MonthlyCostReportId id) {
    auto r = repo.findById(tenantId, id);
    if (r.isNull) return UsecaseResult(false, "", "Monthly cost report not found");
    repo.remove(r);
    return UsecaseResult(true, r.id.value, "");
  }
}
