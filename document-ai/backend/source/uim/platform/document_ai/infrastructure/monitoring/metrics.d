/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Process wide counters of the background processing (exposed by /health).
module uim.platform.document_ai.infrastructure.monitoring.metrics;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

class ProcessingMetrics {
  long runs; /// worker runs
  long extracted; /// documents extracted by the worker
  long failed; /// failed extractions of the worker
  long trainingsCompleted;
  long errors; /// unexpected errors of the worker
  long lastRunAt; /// std time

  void record(const ProcessingSummary s, long trainings, long at) {
    runs++;
    extracted += s.extracted;
    failed += s.failed;
    trainingsCompleted += trainings;
    lastRunAt = at;
  }

  Json toJson() const {
    auto j = Json.emptyObject;
    j["runs"] = runs;
    j["extracted"] = extracted;
    j["failed"] = failed;
    j["trainingsCompleted"] = trainingsCompleted;
    j["errors"] = errors;
    j["lastRunAt"] = isoTimeText(lastRunAt);
    return j;
  }
}

///
unittest {
  auto m = new ProcessingMetrics;
  ProcessingSummary s;
  s.extracted = 2;
  m.record(s, 1, 0);
  assert(m.runs == 1 && m.extracted == 2 && m.toJson()["trainingsCompleted"].get!long == 1);
}
