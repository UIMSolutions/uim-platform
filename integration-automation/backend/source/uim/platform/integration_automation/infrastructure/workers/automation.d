/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Background worker (vibe.d timers, same fiber scheduler as the server):
///   every workerIntervalSeconds  ready automated and notification tasks of
///                                the running workflows of all worker tenants
///   daily (logRetentionDays > 0) execution log entries older than the
///                                retention are purged
/// Runs never overlap and never throw.
module uim.platform.integration_automation.infrastructure.workers.automation;

import vibe.core.core : setTimer, Timer;
import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

class AutomationWorker {
  protected IaPorts ports;
  protected string[] tenants;
  protected uint retentionDays;
  protected Timer runTimer;
  protected Timer purgeTimer;
  protected bool busy;
  size_t runs;
  size_t purges;

  this(IaPorts ports, string[] tenants, uint retentionDays = 0) {
    this.ports = ports;
    this.tenants = tenants;
    this.retentionDays = retentionDays;
  }

  /// Start the periodic runs (0 = disabled).
  void start(uint intervalSeconds) @trusted {
    if (tenants.length == 0)
      return;
    if (intervalSeconds > 0)
      runTimer = setTimer(dur!"seconds"(intervalSeconds), () @safe nothrow { runOnce(); }, true);
    if (retentionDays > 0)
      purgeTimer = setTimer(dur!"hours"(24), () @safe nothrow { purgeOnce(); }, true);
  }

  /// Ready automated and notification tasks of all tenants.
  AutomationRunSummary runOnce() nothrow {
    AutomationRunSummary total;
    if (busy)
      return total;
    busy = true;
    scope (exit)
      busy = false;
    runs++;
    foreach (t; tenants) {
      try {
        auto s = ports.tasks.runAutomation(TenantId(t), UserId(automationActor));
        total.add(s);
        if (s.executed + s.notified > 0)
          logServiceEvent("info", "automation worker run", Json([
              "tenant": Json(t), "executed": Json(s.executed), "succeeded": Json(s.succeeded),
              "failed": Json(s.failed), "notified": Json(s.notified)
            ]));
      } catch (Exception e)
        report(t, e.msg);
    }
    return total;
  }

  /// Purge old execution log entries of all tenants.
  void purgeOnce() nothrow {
    if (busy || retentionDays == 0)
      return;
    busy = true;
    scope (exit)
      busy = false;
    purges++;
    foreach (t; tenants) {
      try {
        auto removed = ports.executions.purge(TenantId(t), cast(int) retentionDays, UserId(automationActor));
        if (removed > 0)
          logServiceEvent("info", "execution log purged", Json([
              "tenant": Json(t), "removed": Json(removed), "olderThanDays": Json(retentionDays)
            ]));
      } catch (Exception e)
        report(t, e.msg);
    }
  }

  protected void report(string tenant, string message) nothrow {
    try
      logServiceEvent("error", "automation worker failed", Json(["tenant": Json(tenant), "error": Json(message)]));
    catch (Exception) {
    }
  }
}
