/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.domain.entities.custom_metric;

import uim.platform.application_autoscaler;

// mixin(ShowModule!());

@safe:

/// A custom metric value submitted by an application or metric producer.
struct CustomMetricEntity {
  mixin TenantEntity!CustomMetricId;

  AppBindingId appId;
  string metricName;
  double value;
  string unit; // e.g. "queue_depth", "jobs", ""
  long timestamp; // Unix millis

  Json toJson() const @safe {
    return entityToJson
      .set("app_id", appId)
      .set("metric_name", metricName)
      .set("value", value)
      .set("unit", unit)
      .set("timestamp", timestamp);
  }
}
