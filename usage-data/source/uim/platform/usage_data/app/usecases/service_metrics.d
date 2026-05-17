/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.usage_data.app.usecases.service_metrics;

import uim.platform.usage_data;

mixin(ShowModule!());
@safe:
/// Application service: service metric catalog use cases.
class ServiceMetricUseCases {
  private ServiceMetricRepository repo;

  this(ServiceMetricRepository repo) {
    this.repo = repo;
  }

  ServiceMetricResponse createMetric(CreateServiceMetricRequest req) {
    MetricUnit unit;
    try { unit = req.unit.to!MetricUnit; } catch (Exception) { unit = MetricUnit.items; }
    auto metric = ServiceMetric.create(req.serviceId, req.serviceName,
      req.planId, req.planName, req.metricName, unit, req.isBillable);
    metric.description = req.description;
    metric.category = req.category;
    repo.save(metric);
    return ServiceMetricResponse.fromEntity(metric);
  }

  ServiceMetricResponse getMetric(TenantId tenantId, ServiceMetricId id) {
    auto m = repo.findById(tenantId, id);
    return ServiceMetricResponse.fromEntity(m);
  }

  ServiceMetricResponse[] listMetrics(TenantId tenantId) {
    ServiceMetricResponse[] result;
    foreach (m; repo.findByTenantId(tenantId))
      result ~= ServiceMetricResponse.fromEntity(m);
    return result;
  }

  ServiceMetricResponse[] listByService(TenantId tenantId, string serviceId) {
    ServiceMetricResponse[] result;
    foreach (m; repo.findByService(tenantId, serviceId))
      result ~= ServiceMetricResponse.fromEntity(m);
    return result;
  }

  ServiceMetricResponse[] listBillable(TenantId tenantId) {
    ServiceMetricResponse[] result;
    foreach (m; repo.findBillable(tenantId))
      result ~= ServiceMetricResponse.fromEntity(m);
    return result;
  }

  CommandResult deleteMetric(TenantId tenantId, ServiceMetricId id) {
    auto m = repo.findById(tenantId, id);
    if (m.isNull) return CommandResult(false, "", "Service metric not found");
    repo.remove(m);
    return CommandResult(true, m.id.value, "");
  }
}
