/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.usage_data.domain.values.types;

import uim.platform.usage_data;

// mixin(ShowModule!());
@safe:

/// Strongly-typed identifier for a UsageRecord aggregate root.
struct UsageRecordId {
  string value;
  this(string v) { value = v; }
  mixin IdTemplate;
}

/// Strongly-typed identifier for a MonthlyUsageReport aggregate root.
struct MonthlyUsageReportId {
  string value;
  this(string v) { value = v; }
  mixin IdTemplate;
}

/// Strongly-typed identifier for a DailyUsageReport aggregate root.
struct DailyUsageReportId {
  string value;
  this(string v) { value = v; }
  mixin IdTemplate;
}

/// Strongly-typed identifier for a MonthlyCostReport aggregate root.
struct MonthlyCostReportId {
  string value;
  this(string v) { value = v; }
  mixin IdTemplate;
}

/// Strongly-typed identifier for a ServiceMetric aggregate root.
struct ServiceMetricId {
  string value;
  this(string v) { value = v; }
  mixin IdTemplate;
}
