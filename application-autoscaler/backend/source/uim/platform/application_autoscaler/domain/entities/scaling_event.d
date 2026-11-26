/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// An immutable record of a scaling decision (the scaling history):
/// what triggered it, the instances before and after, and the outcome.
module uim.platform.application_autoscaler.domain.entities.scaling_event;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

struct ScalingEvent {
  mixin TenantEntity!ScalingEventId;

  AppBindingId bindingId;
  ScalingPolicyId policyId;
  ScalingRuleId ruleId; /// the breached rule (trigger dynamic)
  ScheduleId scheduleId; /// the active schedule (trigger schedule)
  ScalingTrigger trigger = ScalingTrigger.dynamic;
  ScalingDirection direction = ScalingDirection.none;
  ScalingStatus status = ScalingStatus.ignored;
  int oldInstances;
  int newInstances;
  string metricName;
  double metricValue = 0;
  double threshold = 0;
  string reason; /// human readable cause
  string message; /// platform answer or error

  int delta() const {
    return newInstances - oldInstances;
  }
}

///
unittest {
  ScalingEvent e;
  e.oldInstances = 2;
  e.newInstances = 5;
  assert(e.delta == 3);
}
