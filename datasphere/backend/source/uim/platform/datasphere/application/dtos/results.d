/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Results of the scheduler, the run retention and the demo data.
module uim.platform.datasphere.application.dtos.results;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

/// Outcome of a scheduler run over the due tasks and task chains of a tenant.
struct SchedulerSummary {
  long due;
  long started;
  long completed;
  long failed;
  long skipped; /// due, but the space is locked
  string[] messages;

  void add(const TaskRun r, string name) {
    started++;
    if (r.succeeded)
      completed++;
    else {
      failed++;
      messages ~= name ~ ": " ~ r.message;
    }
  }

  string summary() const {
    return format("%d due: %d started, %d completed, %d failed, %d skipped", due, started, completed, failed, skipped);
  }
}

struct PurgeResult {
  long runs;
}

struct SeedResult {
  long spaces;
  long members;
  long connections;
  long remoteTables;
  long views;
  long dataFlows;
  long tasks;
  long taskChains;
  long accessControls;
  long catalogAssets;
  long runs;
}

///
unittest {
  SchedulerSummary s;
  TaskRun ok;
  ok.status = RunStatus.completed;
  TaskRun bad;
  bad.status = RunStatus.failed;
  bad.message = "connection refused";
  s.due = 2;
  s.add(ok, "a");
  s.add(bad, "b");
  assert(s.completed == 1 && s.failed == 1 && s.messages == ["b: connection refused"]);
  assert(s.summary.startsWith("2 due"));
}
