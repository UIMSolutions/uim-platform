/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Metrics (AI API /lm/metrics): append values, merge tags, query, clear.
module uim.platform.ai_core.application.usecases.manage.metrics;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

class ManageMetricsUseCase : AiCoreInteractor, IManageMetrics {
  this(AiCoreRepositories repos, IClock clock, IAiCoreEventPublisher events, LifecyclePolicy policy) {
    super(repos, clock, events, policy);
  }

  size_t logMetrics(LogMetricsRequest r) {
    auto t = r.tenantId, rg = r.resourceGroupId;
    auto execution = required(repos.executions.findById(t, rg, ExecutionId(r.executionId.strip)),
      "Execution '" ~ r.executionId ~ "'");
    if (r.metrics.length == 0 && r.tags.length == 0)
      throw AiCoreException.invalid("At least one metric or tag is required");
    auto at = now;
    Metric[] values;
    foreach (input; r.metrics) {
      Metric m;
      auto name = input.name.strip;
      stampCreated!(Metric, MetricId)(m, t, r.actor, Metric.idFor(execution.id.value, name, input.step), at);
      m.resourceGroupId = rg;
      m.executionId = execution.id;
      m.name = name;
      m.value = input.value;
      m.step = input.step;
      m.timestamp = input.timestamp > 0 ? input.timestamp : at;
      m.labels = checkedLabels(input.labels);
      m.validate();
      values ~= m;
    }
    foreach (m; values) // validate all before storing any
      repos.metrics.save(m);
    if (r.tags.length > 0) {
      foreach (tag; checkedLabels(r.tags))
        execution.tags = setLabel(execution.tags, tag.key, tag.value);
      stampUpdated(execution, r.actor, at);
      repos.executions.save(execution);
    }
    emit("metrics.logged", t, resourceKey(rg.value, execution.id.value), Json(["values": Json(values.length)]));
    return values.length;
  }

  Metric[] listMetrics(TenantId t, ResourceGroupId rg, ExecutionId execution = ExecutionId.init) {
    auto all = execution.isNull ? repos.metrics.findByGroup(t, rg) : repos.metrics.findByExecution(t, rg, execution);
    return all.sort!((a, b) => a.executionId.value != b.executionId.value ? a.executionId.value < b.executionId.value
        : a.name != b.name ? a.name < b.name : a.step < b.step).array;
  }

  Metric getMetric(TenantId t, ResourceGroupId rg, MetricId id) {
    return required(repos.metrics.findById(t, rg, id), "Metric '" ~ id.value ~ "'");
  }

  void deleteMetric(TenantId t, ResourceGroupId rg, MetricId id) {
    getMetric(t, rg, id);
    repos.metrics.removeById(t, rg, id);
  }

  size_t clearMetrics(TenantId t, ResourceGroupId rg, ExecutionId execution) {
    required(repos.executions.findById(t, rg, execution), "Execution '" ~ execution.value ~ "'");
    return repos.metrics.removeByExecution(t, rg, execution);
  }
}
