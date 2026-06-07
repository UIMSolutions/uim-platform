/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.usage_data.domain.entities.daily_usage_report;

import uim.platform.usage_data;

// mixin(ShowModule!());
@safe:

/// Aggregated daily usage report for a specific subaccount for a given date.
/// Corresponds to the "Subaccount usage" API in SAP Usage Data Management Service.
struct DailyUsageReport {
  mixin TenantEntity!DailyUsageReportId;

  string globalAccountId;
  string subaccountId;
  string reportDate; /// YYYY-MM-DD
  int reportYear;
  int reportMonth;
  int reportDay;
  SysTime generatedAt;
  ReportStatus status;
  MetricUsageItem[] usageItems;

  Json toJson() {
    Json jItems = Json.emptyArray;
    foreach (item; usageItems) jItems ~= item.toJson();
    return entityToJson()
      .set("globalAccountId", globalAccountId)
      .set("subaccountId", subaccountId)
      .set("reportDate", reportDate)
      .set("reportYear", reportYear)
      .set("reportMonth", reportMonth)
      .set("reportDay", reportDay)
      .set("generatedAt", generatedAt.toISOExtString())
      .set("status", status.to!string)
      .set("usageItems", jItems);
  }

  static DailyUsageReport create(string globalAccountId, string subaccountId,
      int year, int month, int day) {
    DailyUsageReport r;
    r.id = DailyUsageReportId(randomUUID().toString());
    r.globalAccountId = globalAccountId;
    r.subaccountId = subaccountId;
    r.reportYear = year;
    r.reportMonth = month;
    r.reportDay = day;
    import std.format : format;
    r.reportDate = format!"%04d-%02d-%02d"(year, month, day);
    r.generatedAt = Clock.currTime();
    r.status = ReportStatus.pending;
    return r;
  }
}
