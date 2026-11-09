/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.infrastructure.workers.retention_worker;

import core.time : minutes;
import vibe.core.core : Timer, setTimer;
import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

/// Background task: periodically enforces retention for the configured tenants.
/// Runs inside the vibe.d event loop of the HTTP server.
class RetentionWorker {
  protected IEnforceRetentionUseCase useCase;
  protected string[] tenants;
  protected Timer timer;

  this(IEnforceRetentionUseCase useCase, string[] tenants) {
    this.useCase = useCase;
    this.tenants = tenants;
  }

  /// Start the periodic run. Does nothing if intervalMinutes <= 0.
  void start(int intervalMinutes) {
    if (intervalMinutes <= 0 || tenants.length == 0)
      return;
    timer = setTimer(intervalMinutes.minutes, () nothrow @safe {
      try
        runOnce();
      catch (Exception e)
        logError("auditlog: retention run failed: %s", e.msg);
    }, true);
    logInfo("auditlog: retention worker every %d min for %s", intervalMinutes, tenants);
  }

  /// Run enforcement once for all tenants.
  void runOnce() {
    foreach (t; tenants) {
      auto result = useCase.enforce(TenantId(t));
      logInfo("auditlog: retention %s: %s", t, result.message);
    }
  }

  void stop() {
    if (timer)
      timer.stop();
  }
}
