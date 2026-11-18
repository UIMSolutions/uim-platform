/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.infrastructure.workers.scheduler;

import core.time : seconds;
import vibe.core.core : Timer, setTimer;
import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// Background task: periodically runs the due scheduled jobs of the configured
/// tenants and purges old log entries (inside the vibe.d event loop).
class JobScheduler {
  protected IManageProvisioningJobsUseCase jobs;
  protected IProvisioningLogsQuery logs;
  protected string[] tenants;
  protected int retentionDays;
  protected Timer timer;

  this(IManageProvisioningJobsUseCase jobs, IProvisioningLogsQuery logs, string[] tenants, int retentionDays) {
    this.jobs = jobs;
    this.logs = logs;
    this.tenants = tenants;
    this.retentionDays = retentionDays;
  }

  /// Start the periodic run. Does nothing if intervalSeconds <= 0.
  void start(int intervalSeconds) {
    if (intervalSeconds <= 0 || tenants.length == 0)
      return;
    timer = setTimer(intervalSeconds.seconds, () nothrow @safe {
      try
        runOnce();
      catch (Exception e)
        logError("identity-provisioning: scheduler failed: %s", e.msg);
    }, true);
    logInfo("identity-provisioning: scheduler checks due jobs every %d s for %s", intervalSeconds, tenants);
  }

  /// Run the due jobs of all tenants once (at most 10 per tenant and pass).
  void runOnce() {
    foreach (t; tenants) {
      auto report = jobs.runDue(TenantId(t), 0, 10);
      foreach (m; report.messages)
        logInfo("identity-provisioning: [%s] %s", t, m);
      if (retentionDays > 0) {
        auto purged = logs.purge(TenantId(t), retentionDays);
        if (purged > 0)
          logInfo("identity-provisioning: [%s] purged %d log entries older than %d days", t, purged, retentionDays);
      }
    }
  }

  void stop() {
    if (timer)
      timer.stop();
  }
}
