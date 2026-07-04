/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.infrastructure.persistence.memory.custom_metrics;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

class MemoryCustomMetricRepository : TenantRepository!(CustomMetricEntity, CustomMetricId), CustomMetricRepository {

  size_t countByApp(TenantId tenantId, AppBindingId appId) {
    return findByApp(tenantId, appId).length;
  }

  CustomMetricEntity[] findByApp(TenantId tenantId, AppBindingId appId) {
    return findByTenant(tenantId).filter!(m => m.appId == appId).array;
  }

  void removeByApp(TenantId tenantId, AppBindingId appId) {
    findByApp(tenantId, appId).each!(m => remove(m));
  }

  size_t countByAppIdAndName(TenantId tenantId, AppBindingId appId, string metricName) {
    return findByAppIdAndName(tenantId, appId, metricName).length;
  }
  CustomMetricEntity[] findByAppIdAndName(TenantId tenantId, AppBindingId appId, string metricName) {
    return findByApp(tenantId, appId).filter!(m => m.metricName == metricName).array;
  }

  void removeByAppIdAndName(TenantId tenantId, AppBindingId appId, string metricName) {
    findByAppIdAndName(tenantId, appId, metricName).each!(m => remove(m));
  }

  void removeOlderThan(TenantId tenantId, AppBindingId appId, long cutoffTimestamp) {
    findByApp(tenantId, appId).filter!(m => m.timestamp < cutoffTimestamp).each!(m => remove(m));
  }

}
