/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A measured value of an application metric: standard metrics (cpu,
/// memoryutil, throughput, …) from the platform's metric collector, custom
/// metrics (e.g. "jobqueue") from the application itself.
module uim.platform.application_autoscaler.domain.entities.metric_sample;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

struct MetricSample {
  mixin TenantEntity!MetricSampleId;

  AppBindingId bindingId;
  string metricName; /// a standard metric type value or a custom metric name
  double value = 0;
  string unit;
  long measuredAt; /// std time
  string source = "api"; /// api | app | collector | simulator

  bool isCustom() const {
    return !domainEnumValues!MetricType.canFind(metricName) || metricName == cast(string) MetricType.custom;
  }

  void validate() const {
    import std.math : isFinite;

    requireId(id.value, "Sample ID");
    if (bindingId.isNull)
      throw AasException.invalid("Binding is required");
    if (!isValidMetricName(metricName) || metricName == cast(string) MetricType.custom)
      throw AasException.invalid("Metric name '" ~ metricName ~ "' is invalid (1-100 characters: letters, digits, '_', '-', '.')");
    if (!isFinite(value) || value < 0)
      throw AasException.invalid("Metric value must be a number >= 0");
    requireMaxLength(unit, 20, "Unit");
    requireMaxLength(source, 50, "Source");
    if (measuredAt <= 0)
      throw AasException.invalid("Measurement time is required");
  }
}

///
unittest {
  MetricSample m;
  m.id = MetricSampleId("m");
  m.bindingId = AppBindingId("b");
  m.metricName = "cpu";
  m.value = 42;
  m.measuredAt = 1;
  m.validate();
  assert(!m.isCustom);
  m.metricName = "jobqueue";
  assert(m.isCustom);
  m.value = -1;
  assert(failsWith(AasErrorKind.invalid, () { m.validate(); }));
}
