/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.infrastructure.workers.sync_watchdog;

import core.time : minutes;
import vibe.core.core : Timer, setTimer;
import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// Background task: periodically fails sync sessions that have been running
/// longer than the configured timeout (devices that went offline mid-sync).
/// Runs inside the vibe.d event loop of the HTTP server.
class SyncWatchdogWorker {
  protected IManageSyncSessionsUseCase useCase;
  protected string[] tenants;
  protected int timeoutMinutes;
  protected Timer timer;

  this(IManageSyncSessionsUseCase useCase, string[] tenants, int timeoutMinutes) {
    this.useCase = useCase;
    this.tenants = tenants;
    this.timeoutMinutes = timeoutMinutes;
  }

  /// Start the periodic run. Does nothing if intervalMinutes <= 0.
  void start(int intervalMinutes) {
    if (intervalMinutes <= 0 || tenants.length == 0 || timeoutMinutes <= 0)
      return;
    timer = setTimer(intervalMinutes.minutes, () nothrow @safe {
      try
        runOnce();
      catch (Exception e)
        logError("agentry: sync watchdog failed: %s", e.msg);
    }, true);
    logInfo("agentry: sync watchdog every %d min (timeout %d min) for %s", intervalMinutes, timeoutMinutes, tenants);
  }

  /// Run the check once for all tenants. Returns the number of expired sessions.
  long runOnce() {
    long total;
    foreach (t; tenants) {
      auto result = useCase.expireStaleSessions(TenantId(t), timeoutMinutes);
      if (result.isSuccess)
        total += result.data["expired"].get!long;
      if (result.isSuccess && result.data["expired"].get!long > 0)
        logInfo("agentry: watchdog %s: %s", t, result.message);
    }
    return total;
  }

  void stop() {
    if (timer)
      timer.stop();
  }
}
