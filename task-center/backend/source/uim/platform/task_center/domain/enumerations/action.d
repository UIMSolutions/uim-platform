/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.domain.enumerations.action;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

/// Actions a processor performs on a task. Every action is recorded as a TaskAction.
enum ActionType : string {
  claim = "claim",
  release = "release",
  forward = "forward",
  approve = "approve",
  reject = "reject",
  complete = "complete",
  cancel = "cancel",
  escalate = "escalate",
  resubmit = "resubmit"
}

/// Actions that a task's allowedActions list restricts (claim, release and
/// forward are workflow mechanics and always available when the state allows).
bool isRestrictable(ActionType a) pure nothrow {
  return a != ActionType.claim && a != ActionType.release && a != ActionType.forward;
}

/// Decisions need a claim when the definition requires one.
bool isDecision(ActionType a) pure nothrow {
  return a == ActionType.approve || a == ActionType.reject || a == ActionType.complete;
}
