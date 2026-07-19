/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.usage_data.app.dto.daily_usage_report;

import uim.platform.usage_data;
mixin(ShowModule!());
@safe:

struct CreateDailyUsageReportRequest {
  string globalAccountId;
  string subaccountId;
  int reportYear;
  int reportMonth;
  int reportDay;
}

struct DailyUsageReportResponse {
  DailyUsageReportId reportId;
  TenantId tenantId;
  string globalAccountId;
  string subaccountId;
  string reportDate;
  long generatedAt;
  string status;
  MetricUsageItemResponse[] usageItems;

  bool isEmpty() const { return reportId.value.length == 0; }

  static DailyUsageReportResponse fromEntity(DailyUsageReport r) {
    if (r.isNull) return DailyUsageReportResponse.init;
    MetricUsageItemResponse[] items;
    foreach (i; r.usageItems)
      items ~= MetricUsageItemResponse(i.subaccountId, i.serviceId, i.serviceName,
        i.planId, i.planName, i.metricName, i.value, i.unit, i.environment.to!string);
    return DailyUsageReportResponse(r.id, r.tenantId, r.globalAccountId,
      r.subaccountId, r.reportDate, r.generatedAt.toISOExtString(),
      r.status.to!string, items);
  }
}
