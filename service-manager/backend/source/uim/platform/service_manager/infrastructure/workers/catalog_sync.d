/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Periodic catalog sync of all active brokers (catalogSyncMinutes > 0).
module uim.platform.service_manager.infrastructure.workers.catalog_sync;

import core.time : minutes;
import vibe.core.core : setTimer, Timer;
import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class CatalogSyncWorker {
  protected ISyncBrokerCatalog sync;
  protected string[] tenants;
  protected Timer timer;

  this(ISyncBrokerCatalog sync, string[] tenants) {
    this.sync = sync;
    this.tenants = tenants;
  }

  /// Start the periodic timer (no-op for 0).
  void start(uint intervalMinutes) {
    if (intervalMinutes == 0)
      return;
    timer = setTimer(intervalMinutes.minutes, &tick, true);
    logServiceEvent("info", "catalog sync worker started", Json(["intervalMinutes": Json(intervalMinutes)]));
  }

  void stop() {
    if (timer)
      timer.stop();
  }

  /// One sync round over all configured tenants.
  void tick() nothrow {
    foreach (t; tenants) {
      try {
        auto results = sync.syncAll(TenantId(t), UserId("catalog-sync"));
        auto failed = results.count!(r => !r.succeeded);
        logServiceEvent(failed ? "warn" : "info", "catalog sync", Json([
              "tenant": Json(t), "brokers": Json(results.length), "failed": Json(failed)
            ]));
      } catch (Exception e) {
        try
          logServiceEvent("error", "catalog sync failed", Json([
                "tenant": Json(t), "error": Json(e.msg)
              ]));
        catch (Exception) {
        }
      }
    }
  }
}
