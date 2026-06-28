/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.usage_data.infrastructure.persistence.memory.repositories.service_metric;

import uim.platform.usage_data;

// mixin(ShowModule!());
@safe:
/// In-memory adapter implementing ServiceMetricRepository port.
class MemoryServiceMetricRepository
    : TenantRepository!(ServiceMetric, ServiceMetricId), ServiceMetricRepository {

  ServiceMetric[] findByService(TenantId tenantId, string serviceId) {
    return find(tenantId).filter!(m => m.serviceId == serviceId).array;
  }

  ServiceMetric[] findByPlan(TenantId tenantId, string planId) {
    return find(tenantId).filter!(m => m.planId == planId).array;
  }

  ServiceMetric[] findBillable(TenantId tenantId) {
    return find(tenantId).filter!(m => m.isBillable).array;
  }

  ServiceMetric[] findByCommercialModel(TenantId tenantId, CommercialModel model) {
    return find(tenantId).filter!(m => m.commercialModel == model).array;
  }

  size_t countByService(TenantId tenantId, string serviceId) {
    return findByService(tenantId, serviceId).length;
  }

  void removeByService(TenantId tenantId, string serviceId) {
    foreach (m; findByService(tenantId, serviceId))
      remove(m);
  }
}
