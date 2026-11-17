/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.workers.housekeeping_worker;

import core.time : seconds;
import vibe.core.core : Timer, setTimer;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Background task: periodically runs housekeeping for the configured tenants
/// (inside the vibe.d event loop of the HTTP server).
class HousekeepingWorker {
  protected IHousekeepingUseCase useCase;
  protected string[] tenants;
  protected Timer timer;

  this(IHousekeepingUseCase useCase, string[] tenants) {
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
        logError("workzone: housekeeping failed: %s", e.msg);
    }, true);
    logInfo("workzone: housekeeping every %d s for %s", intervalSeconds, tenants);
  }

  /// Run housekeeping for all tenants once.
  void runOnce() {
    foreach (t; tenants) {
      auto report = useCase.run(TenantId(t));
      foreach (change; report.changes)
        logInfo("workzone: [%s] %s", t, change);
    }
  }

  void stop() {
    if (timer)
      timer.stop();
  }
}
