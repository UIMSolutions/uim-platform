/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.usage_data.app.dto.monthly_cost_report;

import uim.platform.usage_data;

// mixin(ShowModule!());
@safe:

struct CreateMonthlyCostReportRequest {
  string globalAccountId;
  string subaccountId;
  int reportingYear;
  int reportingMonth;
  string currency;
}

struct CostItemResponse {
  string serviceId;
  string serviceName;
  string planId;
  string planName;
  string metricName;
  double amount;
  string currency;
  string unit;
  string commercialModel;
}

struct MonthlyCostReportResponse {
  MonthlyCostReportId reportId;
  TenantId tenantId;
  string globalAccountId;
  string subaccountId;
  int reportingYear;
  int reportingMonth;
  string reportingPeriod;
  string currency;
  double totalCost;
  string commercialModel;
  string status;
  long generatedAt;
  CostItemResponse[] costItems;

  bool isEmpty() const { return reportId.value.length == 0; }

  static MonthlyCostReportResponse fromEntity(MonthlyCostReport r) {
    if (r.isNull) return MonthlyCostReportResponse.init;
    CostItemResponse[] items;
    foreach (i; r.costItems)
      items ~= CostItemResponse(i.serviceId, i.serviceName, i.planId, i.planName,
        i.metricName, i.amount, i.currency, i.unit, i.commercialModel.to!string);
    return MonthlyCostReportResponse(r.id, r.tenantId, r.globalAccountId,
      r.subaccountId, r.reportingYear, r.reportingMonth, r.reportingPeriod,
      r.currency, r.totalCost, r.commercialModel.to!string, r.status.to!string,
      r.generatedAt.toISOExtString(), items);
  }
}
