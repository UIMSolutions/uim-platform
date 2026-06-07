/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.usage_data.domain.entities.monthly_cost_report;

import uim.platform.usage_data;

// mixin(ShowModule!());
@safe:

/// One cost line in a MonthlyCostReport — cost for a service/plan/metric combo.
struct CostItem {
  string serviceId;
  string serviceName;
  string planId;
  string planName;
  string metricName;
  double amount;
  string currency;
  string unit;
  CommercialModel commercialModel;

  Json toJson() {
    return Json.emptyObject
      .set("serviceId", serviceId)
      .set("serviceName", serviceName)
      .set("planId", planId)
      .set("planName", planName)
      .set("metricName", metricName)
      .set("amount", amount)
      .set("currency", currency)
      .set("unit", unit)
      .set("commercialModel", commercialModel.to!string);
  }
}

/// Monthly cost report for a subaccount under a CPEA commercial model.
/// Corresponds to the "Monthly subaccount costs" API in SAP Usage Data Management Service.
struct MonthlyCostReport {
  mixin TenantEntity!MonthlyCostReportId;

  string globalAccountId;
  string subaccountId;
  int reportingYear;
  int reportingMonth;
  string reportingPeriod; /// YYYY-MM
  string currency;
  double totalCost;
  CommercialModel commercialModel;
  ReportStatus status;
  SysTime generatedAt;
  CostItem[] costItems;

  Json toJson() {
    Json jItems = Json.emptyArray;
    foreach (item; costItems) jItems ~= item.toJson();
    return entityToJson()
      .set("globalAccountId", globalAccountId)
      .set("subaccountId", subaccountId)
      .set("reportingYear", reportingYear)
      .set("reportingMonth", reportingMonth)
      .set("reportingPeriod", reportingPeriod)
      .set("currency", currency)
      .set("totalCost", totalCost)
      .set("commercialModel", commercialModel.to!string)
      .set("status", status.to!string)
      .set("generatedAt", generatedAt.toISOExtString())
      .set("costItems", jItems);
  }

  static MonthlyCostReport create(string globalAccountId, string subaccountId,
      int year, int month, string currency) {
    MonthlyCostReport r;
    r.id = MonthlyCostReportId(randomUUID().toString());
    r.globalAccountId = globalAccountId;
    r.subaccountId = subaccountId;
    r.reportingYear = year;
    r.reportingMonth = month;
    import std.format : format;
    r.reportingPeriod = format!"%04d-%02d"(year, month);
    r.currency = currency;
    r.totalCost = 0.0;
    r.commercialModel = CommercialModel.cpea;
    r.status = ReportStatus.pending;
    r.generatedAt = Clock.currTime();
    return r;
  }
}
