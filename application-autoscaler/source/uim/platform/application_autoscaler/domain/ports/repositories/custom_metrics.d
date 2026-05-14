/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.domain.ports.repositories.custom_metrics;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

interface CustomMetricRepository {
  bool                existsById(CustomMetricId id);
  CustomMetricEntity  findById(CustomMetricId id);
  CustomMetricEntity[] findByAppId(AppBindingId appId);
  CustomMetricEntity[] findByAppIdAndName(AppBindingId appId, string metricName);
  void save(CustomMetricEntity metric);
  void removeOlderThan(AppBindingId appId, long cutoffTimestamp);
  size_t countByAppId(AppBindingId appId);
}
