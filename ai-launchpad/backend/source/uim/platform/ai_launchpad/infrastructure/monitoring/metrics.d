/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Process wide counters of the reconcile worker (exposed by /health).
module uim.platform.ai_launchpad.infrastructure.monitoring.metrics;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

class ReconcileMetrics {
  long runs; /// worker runs
  long checked;
  long changes;
  long failed; /// executions failed + deployments dead
  long purgedLogEntries;
  long errors; /// unexpected errors of the worker
  long lastRunAt; /// std time

  void record(const ReconcileSummary s, long at) {
    runs++;
    checked += s.checked;
    changes += s.changes;
    failed += s.failed + s.dead;
    lastRunAt = at;
  }

  void recordPurge(const PurgeResult p) {
    purgedLogEntries += p.entries;
  }

  Json toJson() const {
    auto j = Json.emptyObject;
    j["runs"] = runs;
    j["checked"] = checked;
    j["changes"] = changes;
    j["failed"] = failed;
    j["purgedLogEntries"] = purgedLogEntries;
    j["errors"] = errors;
    j["lastRunAt"] = isoTimeText(lastRunAt);
    return j;
  }
}

///
unittest {
  auto m = new ReconcileMetrics;
  ReconcileSummary s;
  s.checked = 3;
  s.completed = 2;
  m.record(s, 0);
  m.recordPurge(PurgeResult(5));
  assert(m.runs == 1 && m.changes == 2 && m.toJson()["purgedLogEntries"].get!long == 5);
}
