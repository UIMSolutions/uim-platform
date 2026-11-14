/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.infrastructure.workers.health_check_worker;

import core.time : seconds;
import vibe.core.core : Timer, setTimer;
import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// Background task: periodically runs the health check for the configured
/// tenants (inside the vibe.d event loop of the HTTP server).
class HealthCheckWorker {
  protected IHealthCheckUseCase useCase;
  protected string[] tenants;
  protected Timer timer;

  this(IHealthCheckUseCase useCase, string[] tenants) {
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
        logError("connectivity: health check failed: %s", e.msg);
    }, true);
    logInfo("connectivity: health check every %d s for %s", intervalSeconds, tenants);
  }

  /// Check all tenants once.
  void runOnce() {
    foreach (t; tenants) {
      auto report = useCase.run(TenantId(t));
      foreach (change; report.changes)
        logInfo("connectivity: [%s] %s", t, change);
    }
  }

  void stop() {
    if (timer)
      timer.stop();
  }
}
