/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A metric value logged by an execution (loss, accuracy, …). Metrics are
/// append only; logging the same name and step again replaces the value.
module uim.platform.ai_core.domain.entities.metric;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

struct Metric {
  mixin TenantEntity!MetricId;

  ResourceGroupId resourceGroupId;
  ExecutionId executionId;
  string name;
  double value = 0;
  long step;
  long timestamp;
  Label[] labels;

  /// Deterministic id: one value per (execution, name, step).
  static string idFor(string executionId, string name, long step) {
    return executionId ~ "." ~ name ~ "." ~ step.to!string;
  }

  void validate() const {
    requireText(executionId.value, "Execution ID");
    if (!isValidBindingKey(name))
      throw AiCoreException.invalid("Invalid metric name '" ~ name ~ "'");
    if (step < 0)
      throw AiCoreException.invalid("Metric step must not be negative");
  }
}
