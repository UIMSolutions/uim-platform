/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.usage_data.app.dto.monthly_cost_report;

import uim.platform.usage_data;

mixin(ShowModule!());
@safe:

struct CreateMonthlyCostReportRequest {
  GlobalAccountId globalAccountId;
  SubaccountId subaccountId;
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
  GlobalAccountId globalAccountId;
  SubaccountId subaccountId;
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

    auto report = MonthlyCostReportResponse();
    report.reportId = r.id;
    report.tenantId = r.tenantId;
    report.globalAccountId = r.globalAccountId;
    report.subaccountId = r.subaccountId;
    report.reportingYear = r.reportingYear;
    report.reportingMonth = r.reportingMonth;
    report.reportingPeriod = r.reportingPeriod;
    report.currency = r.currency;
    report.totalCost = r.totalCost;
    report.commercialModel = r.commercialModel.to!string;
    report.status = r.status.to!string;
    report.generatedAt = r.generatedAt;
    report.costItems = items;
    return report;
  }
}
