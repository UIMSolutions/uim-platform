/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Results of the scaling engine, the retention purge and the demo data.
module uim.platform.application_autoscaler.application.dtos.results;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

/// Outcome of evaluating (or manually scaling) one binding.
struct EvaluationResult {
  AppBindingId bindingId;
  string bindingName;
  ScalingTrigger trigger = ScalingTrigger.dynamic;
  ScalingDirection direction = ScalingDirection.none;
  ScalingStatus status = ScalingStatus.ignored;
  int oldInstances;
  int newInstances;
  int minInstances; /// limits that applied
  int maxInstances;
  string limitSource; /// "policy" or the schedule
  string reason;
  string message;
  ScalingEventId eventId; /// recorded history entry ("" if nothing changed)
}

/// Outcome of an evaluation run over all bindings of a tenant.
struct EvaluationSummary {
  long bindings;
  long evaluated;
  long scaledOut;
  long scaledIn;
  long unchanged;
  long failed;
  long skipped; /// suspended or without (active) policy
  string[] messages;

  void add(const EvaluationResult r) {
    evaluated++;
    if (r.status == ScalingStatus.failed)
      failed++;
    else if (r.direction == ScalingDirection.scaleOut)
      scaledOut++;
    else if (r.direction == ScalingDirection.scaleIn)
      scaledIn++;
    else
      unchanged++;
    if (r.status != ScalingStatus.ignored)
      messages ~= r.bindingName ~ ": " ~ r.oldInstances.to!string ~ " → " ~ r.newInstances.to!string ~ " (" ~ r.reason ~ ")";
  }
}

struct PurgeResult {
  long samples;
  long events;
}

struct SeedResult {
  long bindings;
  long policies;
  long rules;
  long schedules;
  long samples;
}

///
unittest {
  EvaluationSummary s;
  EvaluationResult r;
  r.direction = ScalingDirection.scaleOut;
  r.status = ScalingStatus.succeeded;
  r.bindingName = "shop";
  r.oldInstances = 1;
  r.newInstances = 2;
  s.add(r);
  s.add(EvaluationResult.init);
  assert(s.evaluated == 2 && s.scaledOut == 1 && s.unchanged == 1 && s.messages.length == 1);
}
