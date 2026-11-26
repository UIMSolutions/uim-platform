/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Background worker (vibe.d timer, same fiber scheduler as the server):
/// every evaluationIntervalSeconds the autoscaled bindings of all worker
/// tenants are evaluated; every purgeEveryRuns-th run the metric samples
/// and scaling events beyond their retention are purged.
/// Runs never overlap and never throw.
module uim.platform.application_autoscaler.infrastructure.workers.scaling;

import vibe.core.core : setTimer, Timer;
import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

class ScalingWorker {
  protected AasPorts ports;
  protected string[] tenants;
  protected uint purgeEvery;
  protected Timer timer;
  protected bool busy;
  WorkerMetrics metrics;

  this(AasPorts ports, string[] tenants, uint purgeEvery = 20, WorkerMetrics metrics = null) {
    this.ports = ports;
    this.tenants = tenants;
    this.purgeEvery = purgeEvery > 0 ? purgeEvery : 1;
    this.metrics = metrics !is null ? metrics : new WorkerMetrics;
  }

  /// Start the periodic runs (0 = disabled).
  void start(uint intervalSeconds) @trusted {
    if (tenants.length == 0 || intervalSeconds == 0)
      return;
    timer = setTimer(dur!"seconds"(intervalSeconds), () @safe nothrow { runOnce(); }, true);
  }

  /// One run over all tenants.
  EvaluationSummary runOnce() nothrow {
    EvaluationSummary total;
    if (busy)
      return total;
    busy = true;
    scope (exit)
      busy = false;
    auto purge = (metrics.runs + 1) % purgeEvery == 0;
    foreach (t; tenants) {
      try {
        auto s = ports.scaling.evaluateAll(TenantId(t), UserId(workerActor));
        total.bindings += s.bindings;
        total.evaluated += s.evaluated;
        total.scaledOut += s.scaledOut;
        total.scaledIn += s.scaledIn;
        total.unchanged += s.unchanged;
        total.failed += s.failed;
        total.skipped += s.skipped;
        total.messages ~= s.messages;
        if (s.scaledOut + s.scaledIn + s.failed > 0)
          logServiceEvent("info", "scaling worker run", Json([
              "tenant": Json(t), "evaluated": Json(s.evaluated), "scaledOut": Json(s.scaledOut),
              "scaledIn": Json(s.scaledIn), "failed": Json(s.failed)
            ]));
        if (purge)
          metrics.recordPurge(ports.metrics.purge(TenantId(t), UserId(workerActor)));
      } catch (Exception e) {
        metrics.errors++;
        report(t, e.msg);
      }
    }
    try
      metrics.record(total, nowStdTime());
    catch (Exception) {
    }
    return total;
  }

  protected void report(string tenant, string message) nothrow {
    try
      logServiceEvent("error", "scaling worker failed", Json(["tenant": Json(tenant), "error": Json(message)]));
    catch (Exception) {
    }
  }
}
