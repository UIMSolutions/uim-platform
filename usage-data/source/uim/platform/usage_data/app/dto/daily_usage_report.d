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
  GlobalAccountId globalAccountId;
  SubaccountId subaccountId;
  int reportYear;
  int reportMonth;
  int reportDay;
}

struct DailyUsageReportResponse {
  DailyUsageReportId reportId;
  TenantId tenantId;
  GlobalAccountId globalAccountId;
  SubaccountId subaccountId;
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

    auto report = DailyUsageReportResponse();
    report.reportId = r.id;
    report.tenantId = r.tenantId;
    report.globalAccountId = r.globalAccountId;
    report.subaccountId = r.subaccountId;
    report.reportDate = r.reportDate;
    report.generatedAt = r.generatedAt;
    report.status = r.status.to!string;
    report.usageItems = items;
    return report;
  }
}
