/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.usage_data.domain.ports.repositories.service_metric;

import uim.platform.usage_data;

mixin(ShowModule!());
@safe:
/// Port: outgoing repository interface for ServiceMetric persistence.
interface ServiceMetricRepository
    : ITenantRepository!(ServiceMetric, ServiceMetricId) {

  ServiceMetric[] findByService(TenantId tenantId, string serviceId);
  ServiceMetric[] findByPlan(TenantId tenantId, string planId);
  ServiceMetric[] findBillable(TenantId tenantId);
  ServiceMetric[] findByCommercialModel(TenantId tenantId, CommercialModel model);
  size_t countByService(TenantId tenantId, string serviceId);
  void removeByService(TenantId tenantId, string serviceId);
}
