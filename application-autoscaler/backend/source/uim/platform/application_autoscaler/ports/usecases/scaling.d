/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving port of the scaling engine and the scaling history.
module uim.platform.application_autoscaler.ports.usecases.scaling;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

interface IScalingEngine {
  /// Evaluate the policy of one binding now and apply the decision.
  EvaluationResult evaluate(TenantId t, AppBindingId binding, UserId actor);
  /// Evaluate every autoscaled binding of the tenant (worker, operators).
  EvaluationSummary evaluateAll(TenantId t, UserId actor);
  /// Set the instances by hand (within 1 .. the policy maximum, or the global limit without policy).
  EvaluationResult scaleManually(TenantId t, AppBindingId binding, int instances, string reason, UserId actor);
  /// What the engine would decide now (nothing is changed).
  ScalingDecision preview(TenantId t, AppBindingId binding);

  ScalingEvent getEvent(TenantId t, ScalingEventId id);
  ScalingEvent[] listEvents(TenantId t);
}
