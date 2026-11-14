/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.infrastructure.workers.cleanup;

import core.time : minutes;
import vibe.core.core : Timer, setTimer;
import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Background task: periodically removes expired sessions and tokens so the
/// stores (and snapshot files) do not grow without bound. Runs inside the
/// vibe.d event loop of the HTTP server.
class ExpiryCleanupWorker {
  protected IManageSessionsUseCase sessions;
  protected ITokenUseCase tokens;
  protected string[] tenants;
  protected Timer timer;

  this(IManageSessionsUseCase sessions, ITokenUseCase tokens, string[] tenants) {
    this.sessions = sessions;
    this.tokens = tokens;
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
        logError("identity-authentication: cleanup failed: %s", e.msg);
    }, true);
    logInfo("identity-authentication: expiry cleanup every %d min for %s", intervalMinutes, tenants);
  }

  /// Purge once for all tenants. Returns the number of removed records.
  long runOnce() {
    long total;
    foreach (t; tenants) {
      auto s = sessions.purgeExpired(TenantId(t));
      auto k = tokens.purgeExpired(TenantId(t));
      auto removed = s.data["removed"].get!long + k.data["removed"].get!long;
      if (removed > 0)
        logInfo("identity-authentication: cleanup %s: %s, %s", t, s.message, k.message);
      total += removed;
    }
    return total;
  }

  void stop() {
    if (timer)
      timer.stop();
  }
}
