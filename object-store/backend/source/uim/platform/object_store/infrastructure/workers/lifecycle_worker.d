/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.infrastructure.workers.lifecycle_worker;

import core.time : seconds;
import vibe.core.core : Timer, setTimer;
import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// Background task: periodically applies the lifecycle rules of the
/// configured tenants (inside the vibe.d event loop of the HTTP server).
class LifecycleWorker {
  protected IManageLifecycleRulesUseCase lifecycle;
  protected string[] tenants;
  protected Timer timer;

  this(IManageLifecycleRulesUseCase lifecycle, string[] tenants) {
    this.lifecycle = lifecycle;
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
        logError("object-store: lifecycle worker failed: %s", e.msg);
    }, true);
    logInfo("object-store: applying lifecycle rules every %d s for %s", intervalSeconds, tenants);
  }

  /// Apply the rules of all tenants once.
  void runOnce() {
    foreach (t; tenants) {
      auto report = lifecycle.run(TenantId(t), BucketId.init, nowStdTime(), UserId("lifecycle"));
      foreach (m; report.messages)
        logInfo("object-store: [%s] %s", t, m);
    }
  }

  void stop() {
    if (timer)
      timer.stop();
  }
}
