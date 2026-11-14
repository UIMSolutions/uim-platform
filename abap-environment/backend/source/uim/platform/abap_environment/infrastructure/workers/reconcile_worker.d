/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.infrastructure.workers.reconcile_worker;

import core.time : seconds;
import vibe.core.core : Timer, setTimer;
import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// Background task: periodically runs the reconciler for the configured tenants
/// (inside the vibe.d event loop of the HTTP server).
class ReconcileWorker {
  protected IReconcileUseCase useCase;
  protected string[] tenants;
  protected Timer timer;

  this(IReconcileUseCase useCase, string[] tenants) {
    this.useCase = useCase;
    this.tenants = tenants;
  }

  /// Start the periodic run. Does nothing if intervalSeconds <= 0.
  void start(int intervalSeconds) {
    if (intervalSeconds <= 0 || tenants.length == 0)
      return;
    timer = setTimer(intervalSeconds.seconds, () nothrow @safe {
      try
        runOnce();
      catch (Exception e)
        logError("abap: reconciliation failed: %s", e.msg);
    }, true);
    logInfo("abap: reconciler every %d s for %s", intervalSeconds, tenants);
  }

  /// Reconcile all tenants once.
  void runOnce() {
    foreach (t; tenants) {
      auto report = useCase.reconcile(TenantId(t));
      foreach (change; report.changes)
        logInfo("abap: [%s] %s", t, change);
    }
  }

  void stop() {
    if (timer)
      timer.stop();
  }
}
