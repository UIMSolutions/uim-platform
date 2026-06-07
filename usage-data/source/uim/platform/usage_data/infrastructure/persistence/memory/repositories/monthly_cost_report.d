/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.usage_data.infrastructure.persistence.memory.repositories.monthly_cost_report;

import uim.platform.usage_data;

// mixin(ShowModule!());
@safe:
/// In-memory adapter implementing MonthlyCostReportRepository port.
class MemoryMonthlyCostReportRepository
    : TenantRepository!(MonthlyCostReport, MonthlyCostReportId),
      MonthlyCostReportRepository {

  MonthlyCostReport[] findByGlobalAccount(TenantId tenantId, string globalAccountId) {
    return findByTenant(tenantId).filter!(r => r.globalAccountId == globalAccountId).array;
  }

  MonthlyCostReport[] findBySubaccount(TenantId tenantId, string subaccountId) {
    return findByTenant(tenantId).filter!(r => r.subaccountId == subaccountId).array;
  }

  MonthlyCostReport[] findByPeriod(TenantId tenantId, int year, int month) {
    return findByTenant(tenantId)
      .filter!(r => r.reportingYear == year && r.reportingMonth == month).array;
  }

  MonthlyCostReport[] findByStatus(TenantId tenantId, ReportStatus status) {
    return findByTenant(tenantId).filter!(r => r.status == status).array;
  }

  size_t countBySubaccount(TenantId tenantId, string subaccountId) {
    return findBySubaccount(tenantId, subaccountId).length;
  }

  void removeByStatus(TenantId tenantId, ReportStatus status) {
    foreach (r; findByStatus(tenantId, status))
      remove(r);
  }
}
