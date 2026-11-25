/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The state machine of a run:
///
///   scheduled ─► triggered ─► completed
///                   │  └────► running ─► completed | failed
///                   └───────► failed ─► triggered (retry) | deadLettered
///
/// completed and deadLettered are final.
module uim.platform.job_scheduling.domain.services.run_tracker;

import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:

struct RunTracker {
  static bool canTransition(RunStatus from, RunStatus to) pure {
    final switch (to) {
    case RunStatus.scheduled:
      return false;
    case RunStatus.triggered:
      return from == RunStatus.scheduled || from == RunStatus.failed;
    case RunStatus.running:
      return from == RunStatus.triggered;
    case RunStatus.completed:
      return from == RunStatus.triggered || from == RunStatus.running;
    case RunStatus.failed:
      return from == RunStatus.triggered || from == RunStatus.running;
    case RunStatus.deadLettered:
      return from == RunStatus.failed;
    }
  }

  /// No further transition possible.
  static bool isFinal(RunStatus status) pure {
    return status == RunStatus.completed || status == RunStatus.deadLettered;
  }

  /// Waiting for the endpoint (synchronous call in progress or asynchronous callback pending).
  static bool isActive(RunStatus status) pure {
    return status == RunStatus.triggered || status == RunStatus.running;
  }

  /// Throw ruleViolation if the transition is not allowed.
  static void require(RunStatus from, RunStatus to, string runId) {
    if (!canTransition(from, to))
      throw JobSchedulingException.ruleViolation("Run '" ~ runId ~ "' cannot change from " ~ cast(string) from
          ~ " to " ~ cast(string) to);
  }
}

///
unittest {
  assert(RunTracker.canTransition(RunStatus.scheduled, RunStatus.triggered));
  assert(RunTracker.canTransition(RunStatus.triggered, RunStatus.completed));
  assert(RunTracker.canTransition(RunStatus.running, RunStatus.failed));
  assert(RunTracker.canTransition(RunStatus.failed, RunStatus.triggered));
  assert(RunTracker.canTransition(RunStatus.failed, RunStatus.deadLettered));
  assert(!RunTracker.canTransition(RunStatus.completed, RunStatus.failed));
  assert(!RunTracker.canTransition(RunStatus.scheduled, RunStatus.completed));
  assert(RunTracker.isFinal(RunStatus.deadLettered) && !RunTracker.isFinal(RunStatus.failed));
  assert(failsWith(JsErrorKind.ruleViolation, () { RunTracker.require(RunStatus.completed, RunStatus.running, "r1"); }));
}
