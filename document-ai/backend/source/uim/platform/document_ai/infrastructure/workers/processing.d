/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Background worker (vibe.d timer, same fiber scheduler as the server):
/// every workerIntervalSeconds the pending documents of all worker tenants
/// are extracted (at most maxDocumentsPerRun per tenant) and the running
/// training jobs whose training time is over are completed.
/// Runs never overlap and never throw.
module uim.platform.document_ai.infrastructure.workers.processing;

import vibe.core.core : setTimer, Timer;
import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

class ProcessingWorker {
  protected DaiPorts ports;
  protected string[] tenants;
  protected size_t maxPerRun;
  protected Timer timer;
  protected bool busy;
  ProcessingMetrics metrics;

  this(DaiPorts ports, string[] tenants, size_t maxPerRun, ProcessingMetrics metrics = null) {
    this.ports = ports;
    this.tenants = tenants;
    this.maxPerRun = maxPerRun;
    this.metrics = metrics !is null ? metrics : new ProcessingMetrics;
  }

  /// Start the periodic runs (0 = disabled).
  void start(uint intervalSeconds) @trusted {
    if (tenants.length == 0 || intervalSeconds == 0)
      return;
    timer = setTimer(dur!"seconds"(intervalSeconds), () @safe nothrow { runOnce(); }, true);
  }

  /// One run over all tenants.
  ProcessingSummary runOnce() nothrow {
    ProcessingSummary total;
    if (busy)
      return total;
    busy = true;
    scope (exit)
      busy = false;
    long trainings;
    foreach (t; tenants) {
      try {
        auto s = ports.documents.processPending(TenantId(t), UserId(workerActor), maxPerRun);
        total.add(s);
        auto completed = ports.trainingJobs.advance(TenantId(t), UserId(workerActor));
        trainings += completed;
        if (s.documents + completed > 0)
          logServiceEvent("info", "processing worker run", Json([
              "tenant": Json(t), "documents": Json(s.documents), "extracted": Json(s.extracted),
              "failed": Json(s.failed), "trainingsCompleted": Json(completed)
            ]));
      } catch (Exception e) {
        metrics.errors++;
        report(t, e.msg);
      }
    }
    try
      metrics.record(total, trainings, nowStdTime());
    catch (Exception) {
    }
    return total;
  }

  protected void report(string tenant, string message) nothrow {
    try
      logServiceEvent("error", "processing worker failed", Json(["tenant": Json(tenant), "error": Json(message)]));
    catch (Exception) {
    }
  }
}
