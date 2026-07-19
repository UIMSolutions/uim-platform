/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.usage_data.domain.entities.monthly_usage_report;

import uim.platform.usage_data;
mixin(ShowModule!());
@safe:

/// One line item inside a MonthlyUsageReport — usage for a service/plan/metric combo.
struct MetricUsageItem {
  string subaccountId;
  string serviceId;
  string serviceName;
  string planId;
  string planName;
  string metricName;
  double value;
  string unit;
  Environment environment;

  Json toJson() {
    return Json.emptyObject
      .set("subaccountId", subaccountId)
      .set("serviceId", serviceId)
      .set("serviceName", serviceName)
      .set("planId", planId)
      .set("planName", planName)
      .set("metricName", metricName)
      .set("value", value)
      .set("unit", unit)
      .set("environment", environment.to!string);
  }
}

/// Aggregated monthly usage report across a global account for a given YYYY-MM period.
/// Corresponds to the "Monthly usage" API in SAP Usage Data Management Service.
struct MonthlyUsageReport {
  mixin TenantEntity!MonthlyUsageReportId;

  string globalAccountId;
  int reportingYear;
  int reportingMonth;
  string reportingPeriod; /// YYYY-MM
  SysTime generatedAt;
  ReportStatus status;
  MetricUsageItem[] usageItems;

  Json toJson() {
    Json jItems = Json.emptyArray;
    foreach (item; usageItems) jItems ~= item.toJson();
    return entityToJson()
      .set("globalAccountId", globalAccountId)
      .set("reportingYear", reportingYear)
      .set("reportingMonth", reportingMonth)
      .set("reportingPeriod", reportingPeriod)
      .set("generatedAt", generatedAt.toISOExtString())
      .set("status", status.to!string)
      .set("usageItems", jItems);
  }

  static MonthlyUsageReport create(string globalAccountId, int year, int month) {
    MonthlyUsageReport r;
    r.id = MonthlyUsageReportId(randomUUID().toString());
    r.globalAccountId = globalAccountId;
    r.reportingYear = year;
    r.reportingMonth = month;
    import std.format : format;
    r.reportingPeriod = format!"%04d-%02d"(year, month);
    r.generatedAt = Clock.currTime();
    r.status = ReportStatus.pending;
    return r;
  }
}
