/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.usage_data.domain.ports.repositories.monthly_cost_report;

import uim.platform.usage_data;

// mixin(ShowModule!());
@safe:
/// Port: outgoing repository interface for MonthlyCostReport persistence.
interface MonthlyCostReportRepository
    : ITentRepository!(MonthlyCostReport, MonthlyCostReportId) {

  MonthlyCostReport[] findByGlobalAccount(TenantId tenantId, string globalAccountId);
  MonthlyCostReport[] findBySubaccount(TenantId tenantId, string subaccountId);
  MonthlyCostReport[] findByPeriod(TenantId tenantId, int year, int month);
  MonthlyCostReport[] findByStatus(TenantId tenantId, ReportStatus status);
  size_t countBySubaccount(TenantId tenantId, string subaccountId);
  void removeByStatus(TenantId tenantId, ReportStatus status);
}
