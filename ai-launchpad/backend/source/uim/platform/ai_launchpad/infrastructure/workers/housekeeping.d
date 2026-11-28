/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Background worker (vibe.d timer, same fiber scheduler as the server):
/// every reconcileIntervalSeconds the active executions and deployments of
/// all worker tenants are reconciled with the runtime; every
/// purgeEveryRuns-th run the audit log entries beyond the retention are
/// purged. Runs never overlap and never throw.
module uim.platform.ai_launchpad.infrastructure.workers.housekeeping;

import vibe.core.core : setTimer, Timer;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

class HousekeepingWorker {
  protected AilpPorts ports;
  protected string[] tenants;
  protected uint purgeEvery;
  protected Timer timer;
  protected bool busy;
  ReconcileMetrics metrics;

  this(AilpPorts ports, string[] tenants, uint purgeEvery = 240, ReconcileMetrics metrics = null) {
    this.ports = ports;
    this.tenants = tenants;
    this.purgeEvery = purgeEvery > 0 ? purgeEvery : 1;
    this.metrics = metrics !is null ? metrics : new ReconcileMetrics;
  }

  /// Start the periodic runs (0 = disabled).
  void start(uint intervalSeconds) @trusted {
    if (tenants.length == 0 || intervalSeconds == 0)
      return;
    timer = setTimer(dur!"seconds"(intervalSeconds), () @safe nothrow { runOnce(); }, true);
  }

  /// One run over all tenants.
  ReconcileSummary runOnce() nothrow {
    ReconcileSummary total;
    if (busy)
      return total;
    busy = true;
    scope (exit)
      busy = false;
    auto purge = (metrics.runs + 1) % purgeEvery == 0;
    foreach (t; tenants) {
      try {
        auto s = ports.reconciler.reconcile(TenantId(t), UserId(systemActor));
        total.checked += s.checked;
        total.started += s.started;
        total.completed += s.completed;
        total.failed += s.failed;
        total.deployed += s.deployed;
        total.dead += s.dead;
        total.expired += s.expired;
        total.messages ~= s.messages;
        if (purge)
          metrics.recordPurge(ports.auditLog.purge(TenantId(t), UserId(systemActor)));
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
      logServiceEvent("error", "reconcile failed", Json(["tenant": Json(tenant), "error": Json(message)]));
    catch (Exception) {
    }
  }
}
