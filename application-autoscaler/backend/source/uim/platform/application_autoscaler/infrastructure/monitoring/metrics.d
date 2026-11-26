/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Process wide counters of the scaling worker (exposed by /health).
module uim.platform.application_autoscaler.infrastructure.monitoring.metrics;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

class WorkerMetrics {
  long runs; /// worker runs
  long evaluated; /// bindings evaluated
  long scaledOut;
  long scaledIn;
  long failed; /// failed scalings
  long purgedSamples;
  long purgedEvents;
  long errors; /// unexpected errors of the worker
  long lastRunAt; /// std time

  void record(const EvaluationSummary s, long at) {
    runs++;
    evaluated += s.evaluated;
    scaledOut += s.scaledOut;
    scaledIn += s.scaledIn;
    failed += s.failed;
    lastRunAt = at;
  }

  void recordPurge(const PurgeResult p) {
    purgedSamples += p.samples;
    purgedEvents += p.events;
  }

  Json toJson() const {
    auto j = Json.emptyObject;
    j["runs"] = runs;
    j["evaluated"] = evaluated;
    j["scaledOut"] = scaledOut;
    j["scaledIn"] = scaledIn;
    j["failed"] = failed;
    j["purgedSamples"] = purgedSamples;
    j["purgedEvents"] = purgedEvents;
    j["errors"] = errors;
    j["lastRunAt"] = isoTimeText(lastRunAt);
    return j;
  }
}

///
unittest {
  auto m = new WorkerMetrics;
  EvaluationSummary s;
  s.evaluated = 3;
  s.scaledOut = 1;
  m.record(s, 0);
  m.recordPurge(PurgeResult(5, 1));
  assert(m.runs == 1 && m.evaluated == 3 && m.toJson()["purgedSamples"].get!long == 5);
}
