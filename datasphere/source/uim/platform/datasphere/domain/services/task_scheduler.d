/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.services.task_scheduler;

// import uim.platform.datasphere.domain.types;
import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
struct TaskScheduler {
  static bool isValidCron(string cron) {
    import std.array : split;
    auto parts = cron.split(" ");
    return parts.length == 5;
  }

  static bool canTransition(TaskStatus from, TaskStatus to) {
    if (to == TaskStatus.running) {
      return from == TaskStatus.scheduled || from == TaskStatus.pending;
    }
    if (to == TaskStatus.cancelled) {
      return from == TaskStatus.running || from == TaskStatus.pending || from == TaskStatus.scheduled;
    }
    if (to == TaskStatus.completed) {
      return from == TaskStatus.running;
    }
    if (to == TaskStatus.failed) {
      return from == TaskStatus.running;
    }
    return false;
  }

  static bool canTransitionFlow(FlowStatus from, FlowStatus to) {
    if (to == FlowStatus.running) {
      return from == FlowStatus.active || from == FlowStatus.pending;
    }
    if (to == FlowStatus.inactive) {
      return from == FlowStatus.active || from == FlowStatus.completed || from == FlowStatus.failed;
    }
    if (to == FlowStatus.completed) {
      return from == FlowStatus.running;
    }
    if (to == FlowStatus.failed) {
      return from == FlowStatus.running;
    }
    return false;
  }
}
