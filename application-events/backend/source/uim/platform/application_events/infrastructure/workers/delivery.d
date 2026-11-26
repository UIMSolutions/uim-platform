/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Background worker (vibe.d timer, same fiber scheduler as the server):
/// every dispatchIntervalSeconds the due messages of all worker tenants
/// are delivered (first attempts and retries whose back-off has passed);
/// every purgeEveryRuns-th run the finished messages and resolved dead
/// letters beyond their retention are purged. Runs never overlap and never
/// throw.
module uim.platform.application_events.infrastructure.workers.delivery;

import vibe.core.core : setTimer, Timer;
import uim.platform.application_events;

mixin(ShowModule!());

@safe:

class DeliveryWorker {
  protected AehPorts ports;
  protected string[] tenants;
  protected uint purgeEvery;
  protected Timer timer;
  protected bool busy;
  WorkerMetrics metrics;

  this(AehPorts ports, string[] tenants, uint purgeEvery = 60, WorkerMetrics metrics = null) {
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
  DispatchSummary runOnce() nothrow {
    DispatchSummary total;
    if (busy)
      return total;
    busy = true;
    scope (exit)
      busy = false;
    auto purge = (metrics.runs + 1) % purgeEvery == 0;
    foreach (t; tenants) {
      try {
        auto s = ports.delivery.dispatchDue(TenantId(t), UserId(workerActor));
        total.due += s.due;
        total.attempted += s.attempted;
        total.delivered += s.delivered;
        total.queued += s.queued;
        total.retrying += s.retrying;
        total.deadLettered += s.deadLettered;
        total.dropped += s.dropped;
        total.waiting += s.waiting;
        total.messages ~= s.messages;
        if (s.attempted > 0)
          logServiceEvent("info", "delivery worker run", Json([
              "tenant": Json(t), "attempted": Json(s.attempted), "delivered": Json(s.delivered),
              "retrying": Json(s.retrying), "deadLettered": Json(s.deadLettered)
            ]));
        if (purge)
          metrics.recordPurge(ports.delivery.purge(TenantId(t), UserId(workerActor)));
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
      logServiceEvent("error", "delivery worker failed", Json(["tenant": Json(tenant), "error": Json(message)]));
    catch (Exception) {
    }
  }
}
