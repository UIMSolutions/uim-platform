/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.application.usecases.get_metrics;
// import uim.platform.ai_core.domain.types;
// import uim.platform.ai_core.domain.entities.metric;
// import uim.platform.ai_core.domain.ports.repositories.metric;
// import uim.platform.ai_core.application.dto;


import uim.platform.ai_core;

// mixin(ShowModule!()); 

@safe:
class GetMetricsUseCase { // TODO: UIMUseCase {
  private MetricRepository repo;

  this(MetricRepository repo) {
    this.repo = repo;
  }

  CommandResult patchMetric(PatchMetricsRequest r) {
    if (r.executionId.isEmpty)
      return CommandResult(false, "", "Execution ID is required");
    if (r.resourceGroupId.isEmpty)
      return CommandResult(false, "", "Resource group ID is required");

    Metric metric;
    metric.initEntity(r.tenantId) ;

    metric.resourceGroupId = r.resourceGroupId;
    metric.executionId = r.executionId;

    // Parse metric values
    MetricValue[] vals;
    foreach (pair; r.metrics) {
      if (pair.length >= 2) {
        MetricValue mv;
        mv.name = pair[0];
        mv.value = pair[1];
        mv.type = MetricValueType.string_;
        vals ~= mv;
      }
    }
    metric.metrics = vals;

    // Parse tags
    MetricTag[] tags;
    foreach (pair; r.tags) {
      if (pair.length >= 2) {
        MetricTag mt;
        mt.key = pair[0];
        mt.value = pair[1];
        tags ~= mt;
      }
    }
    metric.tags = tags;

    // Parse custom info
    CustomInfo[] info;
    foreach (pair; r.customInfo) {
      if (pair.length >= 2) {
        CustomInfo ci;
        ci.key = pair[0];
        ci.value = pair[1];
        info ~= ci;
      }
    }
    metric.customInfo = info;

    repo.save(metric);
    return CommandResult(true,  metric.id.value, "");
  }

  Metric[] listMetrics(TenantId tenantId, ResourceGroupId rgId, ExecutionId execId) {
    return repo.findByExecution(tenantId, rgId, execId);
  }

  Metric getMetric(TenantId tenantId, ResourceGroupId rgId, MetricId id) {
    return repo.findById(tenantId, rgId, id);
  }

  CommandResult deleteMetric(TenantId tenantId, ResourceGroupId rgId, MetricId id) {
    auto metric = repo.findById(tenantId, rgId, id);
    if (metric.isNull)
      return CommandResult(false, "", "Metric not found");

    repo.remove(metric);
    return CommandResult(true, metric.id.value, "");
  }
}
