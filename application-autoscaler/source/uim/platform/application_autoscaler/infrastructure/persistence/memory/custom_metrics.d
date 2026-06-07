/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.infrastructure.persistence.memory.custom_metrics;

import uim.platform.application_autoscaler;

// mixin(ShowModule!());

@safe:

class MemoryCustomMetricRepository : CustomMetricRepository {
  private CustomMetricEntity[string] store;

  override bool existsById(CustomMetricId id) {
    return (id in store) !is null;
  }

  override CustomMetricEntity findById(CustomMetricId id) {
    auto p = id in store;
    return p ? *p : CustomMetricEntity.init;
  }

  override CustomMetricEntity[] findByApp(AppBindingId appId) {
    CustomMetricEntity[] result;
    foreach (m; store.byValue)
      if (m.appId == appId) result ~= m;
    return result;
  }

  override CustomMetricEntity[] findByAppIdAndName(AppBindingId appId, string metricName) {
    CustomMetricEntity[] result;
    foreach (m; store.byValue)
      if (m.appId == appId && m.metricName == metricName) result ~= m;
    return result;
  }

  override void save(CustomMetricEntity metric) {
    store[metric.id] = metric;
  }

  override void removeOlderThan(AppBindingId appId, long cutoffTimestamp) {
    string[] toRemove;
    foreach (k, m; store)
      if (m.appId == appId && m.timestamp < cutoffTimestamp) toRemove ~= k;
    foreach (k; toRemove) store.remove(k);
  }

  override size_t countByApp(AppBindingId appId) {
    size_t n;
    foreach (m; store.byValue)
      if (m.appId == appId) n++;
    return n;
  }
}
