/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.usage_data.domain.ports.repositories.monthly_usage_report;

import uim.platform.usage_data;

// mixin(ShowModule!());
@safe:
/// Port: outgoing repository interface for MonthlyUsageReport persistence.
interface MonthlyUsageReportRepository
    : ITentRepository!(MonthlyUsageReport, MonthlyUsageReportId) {

  MonthlyUsageReport[] findByGlobalAccount(TenantId tenantId, string globalAccountId);
  MonthlyUsageReport[] findByPeriod(TenantId tenantId, int year, int month);
  MonthlyUsageReport[] findByStatus(TenantId tenantId, ReportStatus status);
  size_t countByGlobalAccount(TenantId tenantId, string globalAccountId);
  void removeByStatus(TenantId tenantId, ReportStatus status);
}
