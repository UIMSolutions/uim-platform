/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.usage_data.app.dto.monthly_usage_report;

import uim.platform.usage_data;

// mixin(ShowModule!());
@safe:

struct CreateMonthlyUsageReportRequest {
  string globalAccountId;
  int reportingYear;
  int reportingMonth;
}

struct MetricUsageItemResponse {
  string subaccountId;
  string serviceId;
  string serviceName;
  string planId;
  string planName;
  string metricName;
  double value;
  string unit;
  string environment;
}

struct MonthlyUsageReportResponse {
  MonthlyUsageReportId reportId;
  TenantId tenantId;
  string globalAccountId;
  int reportingYear;
  int reportingMonth;
  string reportingPeriod;
  long generatedAt;
  string status;
  MetricUsageItemResponse[] usageItems;

  bool isEmpty() const { return reportId.value.length == 0; }

  static MonthlyUsageReportResponse fromEntity(MonthlyUsageReport r) {
    if (r.isNull) return MonthlyUsageReportResponse.init;
    MetricUsageItemResponse[] items;
    foreach (i; r.usageItems)
      items ~= MetricUsageItemResponse(i.subaccountId, i.serviceId, i.serviceName,
        i.planId, i.planName, i.metricName, i.value, i.unit, i.environment.to!string);
    return MonthlyUsageReportResponse(r.id, r.tenantId, r.globalAccountId,
      r.reportingYear, r.reportingMonth, r.reportingPeriod,
      r.generatedAt.toISOExtString(), r.status.to!string, items);
  }
}
