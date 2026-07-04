/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.domain.services.scaling_evaluator;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

/// Pure domain service: evaluates whether a scaling rule is breached
/// and computes the new instance count. No I/O.
class ScalingEvaluatorService {

  /// Returns the computed new instance count for the given policy
  /// given current metric value. Returns current count if no rule fires.
  int evaluate(
    ScalingPolicyEntity policy,
    string              metricType,
    double              currentValue,
    int                 currentInstances
  ) @safe {
    foreach (rule; policy.scalingRules.filter!(r => r.metricType.to!string == metricType)) {
      bool breached = false;
      final switch (rule.operator) {
        case ScalingOperator.lt:  breached = currentValue <  rule.threshold; break;
        case ScalingOperator.gt:  breached = currentValue >  rule.threshold; break;
        case ScalingOperator.lte: breached = currentValue <= rule.threshold; break;
        case ScalingOperator.gte: breached = currentValue >= rule.threshold; break;
      }
      if (breached)
        return applyAdjustment(rule.adjustment, currentInstances,
          policy.instanceMinCount, policy.instanceMaxCount);
    }
    return currentInstances;
  }

  private int applyAdjustment(string adjustment, int current, int minC, int maxC) @safe {
    import std.string : endsWith, startsWith;
    
    if (adjustment.length == 0) return current;
    bool percentage = adjustment.endsWith("%");
    string raw = percentage ? adjustment[0 .. $-1] : adjustment;
    int delta;
    try {
      delta = raw.to!int;
    } catch (Exception) {
      return current;
    }
    int result;
    if (percentage)
      result = current + (current * delta / 100);
    else
      result = current + delta;
    if (result < minC) result = minC;
    if (result > maxC) result = maxC;
    return result;
  }
}
