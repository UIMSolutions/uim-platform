/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.infrastructure.workers.job_worker;

import core.time : seconds;
import vibe.core.core : Timer, setTimer;
import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// Background task: periodically processes the pending translation jobs of
/// the configured tenants (inside the vibe.d event loop of the HTTP server).
class JobWorker {
  protected IManageJobsUseCase jobs;
  protected string[] tenants;
  protected Timer timer;

  this(IManageJobsUseCase jobs, string[] tenants) {
    this.jobs = jobs;
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
        logError("translation: job worker failed: %s", e.msg);
    }, true);
    logInfo("translation: processing jobs every %d s for %s", intervalSeconds, tenants);
  }

  /// Process the pending jobs of all tenants once (at most 20 per tenant and run).
  void runOnce() {
    foreach (t; tenants) {
      auto report = jobs.processPending(TenantId(t), 20);
      foreach (m; report.messages)
        logInfo("translation: [%s] %s", t, m);
    }
  }

  void stop() {
    if (timer)
      timer.stop();
  }
}
