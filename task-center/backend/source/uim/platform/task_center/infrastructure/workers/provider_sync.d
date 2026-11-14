/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Background federation: syncs all active providers of the configured
/// tenants every syncIntervalSeconds (vibe.d timer; a round is skipped while
/// the previous one still runs).
module uim.platform.task_center.infrastructure.workers.provider_sync;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class ProviderSyncWorker {
  protected ISyncTaskProviders sync;
  protected string[] tenants;
  protected Timer timer;
  protected bool running;

  this(ISyncTaskProviders sync, string[] tenants) {
    this.sync = sync;
    this.tenants = tenants;
  }

  /// Start the periodic timer (no-op for 0).
  void start(uint intervalSeconds) {
    if (intervalSeconds == 0)
      return;
    timer = setTimer(intervalSeconds.seconds, &tick, true);
    logServiceEvent("info", "provider sync worker started", Json(["intervalSeconds": Json(intervalSeconds)]));
  }

  void stop() {
    if (timer)
      timer.stop();
  }

  /// One sync round over all configured tenants.
  void tick() nothrow {
    if (running)
      return;
    running = true;
    scope (exit)
      running = false;
    foreach (t; tenants) {
      try {
        size_t created, updated, failed;
        foreach (r; sync.syncAll(TenantId(t), UserId("provider-sync"))) {
          created += r.created;
          updated += r.updated;
          if (!r.succeeded)
            failed++;
        }
        if (created + updated + failed > 0)
          logServiceEvent(failed ? "warn" : "info", "provider sync", Json([
                "tenant": Json(t), "created": Json(created), "updated": Json(updated), "failedProviders": Json(failed)
              ]));
      } catch (Exception e) {
        try
          logServiceEvent("error", "provider sync failed", Json(["tenant": Json(t), "error": Json(e.msg)]));
        catch (Exception) {
        }
      }
    }
  }
}
