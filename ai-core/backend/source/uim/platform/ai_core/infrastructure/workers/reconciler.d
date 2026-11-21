/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Background worker: runs the lifecycle reconciler for the configured
/// tenants periodically (vibe.d timer, same fiber scheduler as the server).
module uim.platform.ai_core.infrastructure.workers.reconciler;

import vibe.core.core : setTimer, Timer;
import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

class ReconcilerWorker {
  protected IReconcileLifecycle reconciler;
  protected string[] tenants;
  protected Timer timer;
  size_t runs;

  this(IReconcileLifecycle reconciler, string[] tenants) {
    this.reconciler = reconciler;
    this.tenants = tenants;
  }

  /// Start the periodic run (0 = disabled).
  void start(uint intervalSeconds) @trusted {
    if (intervalSeconds == 0 || tenants.length == 0)
      return;
    timer = setTimer(dur!"seconds"(intervalSeconds), () @safe nothrow { runOnce(); }, true);
  }

  /// One run over all tenants (never throws).
  ReconcileResult runOnce() nothrow {
    ReconcileResult total;
    runs++;
    foreach (t; tenants) {
      try {
        auto r = reconciler.reconcile(TenantId(t));
        total.add(r);
        if (r.total > 0)
          logServiceEvent("debug", "reconciled", Json([
              "tenant": Json(t), "changes": Json(r.total), "artifactsCreated": Json(r.artifactsCreated)
            ]));
      } catch (Exception e) {
        try
          logServiceEvent("error", "reconcile failed", Json(["tenant": Json(t), "error": Json(e.msg)]));
        catch (Exception) {
        }
      }
    }
    return total;
  }
}
