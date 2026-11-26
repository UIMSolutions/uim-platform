/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Process wide counters of the delivery worker (exposed by /health).
module uim.platform.application_events.infrastructure.monitoring.metrics;

import uim.platform.application_events;

mixin(ShowModule!());

@safe:

class WorkerMetrics {
  long runs; /// worker runs
  long attempted; /// delivery attempts
  long delivered;
  long queued;
  long retrying;
  long deadLettered;
  long dropped;
  long purgedMessages;
  long purgedDeadLetters;
  long errors; /// unexpected errors of the worker
  long lastRunAt; /// std time

  void record(const DispatchSummary s, long at) {
    runs++;
    attempted += s.attempted;
    delivered += s.delivered;
    queued += s.queued;
    retrying += s.retrying;
    deadLettered += s.deadLettered;
    dropped += s.dropped;
    lastRunAt = at;
  }

  void recordPurge(const PurgeResult p) {
    purgedMessages += p.messages;
    purgedDeadLetters += p.deadLetters;
  }

  Json toJson() const {
    auto j = Json.emptyObject;
    j["runs"] = runs;
    j["attempted"] = attempted;
    j["delivered"] = delivered;
    j["queued"] = queued;
    j["retrying"] = retrying;
    j["deadLettered"] = deadLettered;
    j["dropped"] = dropped;
    j["purgedMessages"] = purgedMessages;
    j["purgedDeadLetters"] = purgedDeadLetters;
    j["errors"] = errors;
    j["lastRunAt"] = isoTimeText(lastRunAt);
    return j;
  }
}

///
unittest {
  auto m = new WorkerMetrics;
  DispatchSummary s;
  s.attempted = 3;
  s.delivered = 2;
  m.record(s, 0);
  m.recordPurge(PurgeResult(5, 1));
  assert(m.runs == 1 && m.delivered == 2 && m.toJson()["purgedMessages"].get!long == 5);
}
