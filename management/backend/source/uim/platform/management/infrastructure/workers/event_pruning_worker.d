/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.infrastructure.workers.event_pruning_worker;

import core.time : minutes;
import vibe.core.core : setTimer, Timer;
import uim.platform.management;

mixin(ShowModule!());

@safe:

/// Background worker: periodically removes platform events older than the
/// configured retention period for the configured tenants.
class EventPruningWorker {
  protected IPruneEventsUseCase pruner;
  protected string[] tenants;
  protected int retentionDays;
  protected Timer timer;

  this(IPruneEventsUseCase pruner, string[] tenants, int retentionDays) {
    this.pruner = pruner;
    this.tenants = tenants;
    this.retentionDays = retentionDays;
  }

  /// Start (intervalMinutes <= 0 or retentionDays <= 0 = disabled).
  void start(int intervalMinutes) {
    if (intervalMinutes <= 0 || retentionDays <= 0)
      return;
    timer = setTimer(intervalMinutes.minutes, () nothrow { runOnce(); }, true);
    logInfo("management: pruning events older than %d days every %d minutes for %s",
      retentionDays, intervalMinutes, tenants);
  }

  void stop() {
    if (timer)
      timer.stop();
  }

  /// One pass over all tenants. Never throws.
  void runOnce() nothrow {
    foreach (tenant; tenants) {
      try {
        auto r = pruner.pruneEvents(TenantId(tenant), retentionDays);
        if (r.isSuccess && r.data["removed"].get!long > 0)
          logInfo("management: %s", r.message);
      } catch (Exception e) {
        try
          logError("management: event pruning for tenant %s failed: %s", tenant, e.msg);
        catch (Exception) {
        }
      }
    }
  }
}
