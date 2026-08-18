/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.ports.usecases.get_metrics;

import uim.platform.ai_core;

mixin(ShowModule!()); 

@safe:
interface GetMetricsUseCase { 

  UsecaseResult patchMetric(PatchMetricsRequest r);
  Metric[] listMetrics(TenantId tenantId, ResourceGroupId rgId, ExecutionId execId);
  Metric getMetric(TenantId tenantId, ResourceGroupId rgId, MetricId id);
  UsecaseResult deleteMetric(TenantId tenantId, ResourceGroupId rgId, MetricId id);

}
