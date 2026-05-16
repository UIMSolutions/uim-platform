/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.domain.ports.repositories.custom_metrics;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

interface CustomMetricRepository : ITenantRepository!(CustomMetricEntity, CustomMetricId) {

  size_t countByAppId(TenantId tenantId, AppBindingId appId);
  CustomMetricEntity[] findByAppId(AppBindingId appId);
  void removeByAppId(TenantId tenantId, AppBindingId appId);

  size_t countByAppIdAndName(TenantId tenantId, AppBindingId appId, string metricName);
  CustomMetricEntity[] findByAppIdAndName(AppBindingId appId, string metricName);
  void removeByAppIdAndName(TenantId tenantId, AppBindingId appId, string metricName);
  
}
