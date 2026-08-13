/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.usage_data.domain.ports.repositories.daily_usage_report;

import uim.platform.usage_data;

mixin(ShowModule!());
@safe:
/// Port: outgoing repository interface for DailyUsageReport persistence.
interface IDailyUsageReportRepository
    : ITenantRepository!(DailyUsageReport, DailyUsageReportId) {

  DailyUsageReport[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId);
  DailyUsageReport[] findByDate(TenantId tenantId, string reportDate);
  DailyUsageReport[] findByStatus(TenantId tenantId, ReportStatus status);
  DailyUsageReport[] findByGlobalAccount(TenantId tenantId, GlobalAccountId globalAccountId);
  size_t countBySubaccount(TenantId tenantId, SubaccountId subaccountId);
  void removeByStatus(TenantId tenantId, ReportStatus status);
}
