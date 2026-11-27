/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Background scheduler (vibe.d timer, same fiber scheduler as the server):
/// every schedulerIntervalSeconds the due tasks and task chains of all
/// worker tenants run; every purgeEveryRuns-th run the finished runs
/// beyond the retention are purged. Runs never overlap and never throw.
module uim.platform.datasphere.infrastructure.workers.scheduler;

import vibe.core.core : setTimer, Timer;
import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

class SchedulerWorker {
  protected DspPorts ports;
  protected string[] tenants;
  protected uint purgeEvery;
  protected Timer timer;
  protected bool busy;
  SchedulerMetrics metrics;

  this(DspPorts ports, string[] tenants, uint purgeEvery = 60, SchedulerMetrics metrics = null) {
    this.ports = ports;
    this.tenants = tenants;
    this.purgeEvery = purgeEvery > 0 ? purgeEvery : 1;
    this.metrics = metrics !is null ? metrics : new SchedulerMetrics;
  }

  /// Start the periodic runs (0 = disabled).
  void start(uint intervalSeconds) @trusted {
    if (tenants.length == 0 || intervalSeconds == 0)
      return;
    timer = setTimer(dur!"seconds"(intervalSeconds), () @safe nothrow { runOnce(); }, true);
  }

  /// One run over all tenants.
  SchedulerSummary runOnce() nothrow {
    SchedulerSummary total;
    if (busy)
      return total;
    busy = true;
    scope (exit)
      busy = false;
    auto purge = (metrics.runs + 1) % purgeEvery == 0;
    foreach (t; tenants) {
      try {
        auto s = ports.monitor.runDue(TenantId(t), UserId(schedulerActor));
        total.due += s.due;
        total.started += s.started;
        total.completed += s.completed;
        total.failed += s.failed;
        total.skipped += s.skipped;
        total.messages ~= s.messages;
        if (s.due > 0)
          logServiceEvent(s.failed > 0 ? "warning" : "info", "scheduler run", Json([
              "tenant": Json(t), "due": Json(s.due), "completed": Json(s.completed), "failed": Json(s.failed),
              "skipped": Json(s.skipped)
            ]));
        if (purge)
          metrics.recordPurge(ports.monitor.purgeRuns(TenantId(t), UserId(schedulerActor)));
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
      logServiceEvent("error", "scheduler failed", Json(["tenant": Json(tenant), "error": Json(message)]));
    catch (Exception) {
    }
  }
}
