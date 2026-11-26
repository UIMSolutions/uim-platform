/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving port of the metric ingestion.
module uim.platform.application_autoscaler.ports.usecases.metrics;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

interface IManageMetrics {
  /// Record one value (binding by id or application GUID).
  MetricSample submit(SubmitMetricRequest r);
  /// Record a constant value over the last durationSeconds (every stepSeconds) — load simulation for tests and demos.
  MetricSample[] simulate(SimulateLoadRequest r);
  MetricSample get(TenantId t, MetricSampleId id);
  MetricSample[] list(TenantId t);
  MetricSample[] listOf(TenantId t, AppBindingId binding);
  void remove(TenantId t, MetricSampleId id, UserId actor);
  /// Remove samples (and scaling events) beyond the retention periods.
  PurgeResult purge(TenantId t, UserId actor);
}
