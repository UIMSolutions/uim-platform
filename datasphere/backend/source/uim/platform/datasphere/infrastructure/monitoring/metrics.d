/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Process wide counters of the scheduler worker (exposed by /health).
module uim.platform.datasphere.infrastructure.monitoring.metrics;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

class SchedulerMetrics {
  long runs; /// worker runs
  long due;
  long started;
  long completed;
  long failed;
  long skipped;
  long purgedRuns;
  long errors; /// unexpected errors of the worker
  long lastRunAt; /// std time

  void record(const SchedulerSummary s, long at) {
    runs++;
    due += s.due;
    started += s.started;
    completed += s.completed;
    failed += s.failed;
    skipped += s.skipped;
    lastRunAt = at;
  }

  void recordPurge(const PurgeResult p) {
    purgedRuns += p.runs;
  }

  Json toJson() const {
    auto j = Json.emptyObject;
    j["runs"] = runs;
    j["due"] = due;
    j["started"] = started;
    j["completed"] = completed;
    j["failed"] = failed;
    j["skipped"] = skipped;
    j["purgedRuns"] = purgedRuns;
    j["errors"] = errors;
    j["lastRunAt"] = isoTimeText(lastRunAt);
    return j;
  }
}

///
unittest {
  auto m = new SchedulerMetrics;
  SchedulerSummary s;
  s.due = 3;
  s.completed = 2;
  m.record(s, 0);
  m.recordPurge(PurgeResult(5));
  assert(m.runs == 1 && m.completed == 2 && m.toJson()["purgedRuns"].get!long == 5);
}
