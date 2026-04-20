/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.domain.entities.metric;

// import uim.platform.monitoring.domain.types;
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
/// A single metric data point.
struct Metric {
  mixin TenantEntity!(MetricId);

  MonitoredResourceId resourceId;
  MetricDefinitionId definitionId;
  string name;
  double value_;
  MetricUnit unit = MetricUnit.none;
  MetricCategory category = MetricCategory.custom;
  string[string] labels;
  long timestamp;

  Json toJson() const {
    auto j = entityToJson
      .set("resourceId", resourceId.value)
      .set("definitionId", definitionId.value)
      .set("name", name)
      .set("value", value_)
      .set("unit", unit.toString())
      .set("category", category.toString())
      .set("labels", labels)
      .set("timestamp", timestamp);

    return j;
  }
}

/// Aggregated metric summary over a time window.
struct MetricSummary {
  string name;
  MonitoredResourceId resourceId;
  double minValue;
  double maxValue;
  double avgValue;
  double sumValue;
  long dataPointCount;
  long windowStartTime;
  long windowEndTime;
}
