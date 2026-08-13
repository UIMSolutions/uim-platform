/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.usage_data.infrastructure.persistence.repositories.repositories.daily_usage_report;

import uim.platform.usage_data;

mixin(ShowModule!());
@safe:
/// In-memory adapter implementing DailyUsageReportRepository port.
class DailyUsageReportRepository
    : TenantRepository!(DailyUsageReport, DailyUsageReportId),
      IDailyUsageReportRepository {

  DailyUsageReport[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    return findByTenant(tenantId).filter!(r => r.subaccountId == subaccountId).array;
  }

  DailyUsageReport[] findByDate(TenantId tenantId, string reportDate) {
    return findByTenant(tenantId).filter!(r => r.reportDate == reportDate).array;
  }

  DailyUsageReport[] findByStatus(TenantId tenantId, ReportStatus status) {
    return findByTenant(tenantId).filter!(r => r.status == status).array;
  }

  DailyUsageReport[] findByGlobalAccount(TenantId tenantId, GlobalAccountId globalAccountId) {
    return findByTenant(tenantId).filter!(r => r.globalAccountId == globalAccountId).array;
  }

  size_t countBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    return findBySubaccount(tenantId, subaccountId).length;
  }

  void removeByStatus(TenantId tenantId, ReportStatus status) {
    foreach (r; findByStatus(tenantId, status))
      remove(r);
  }
}
