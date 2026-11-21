/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Background worker: runs the pending cleansing jobs of the configured
/// tenants periodically (vibe.d timer, same fiber scheduler as the server).
module uim.platform.data_quality.infrastructure.workers.cleansing_jobs;

import vibe.core.core : setTimer, Timer;
import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

class CleansingJobWorker {
  protected IManageCleansingJobs jobs;
  protected string[] tenants;
  protected Timer timer;
  protected bool busy;
  size_t runs;

  this(IManageCleansingJobs jobs, string[] tenants) {
    this.jobs = jobs;
    this.tenants = tenants;
  }

  /// Start the periodic run (0 = disabled).
  void start(uint intervalSeconds) @trusted {
    if (intervalSeconds == 0 || tenants.length == 0)
      return;
    timer = setTimer(dur!"seconds"(intervalSeconds), () @safe nothrow { runOnce(); }, true);
  }

  /// One run over all tenants (never throws, never overlaps).
  JobRunSummary runOnce() nothrow {
    JobRunSummary total;
    if (busy)
      return total;
    busy = true;
    scope (exit)
      busy = false;
    runs++;
    foreach (t; tenants) {
      try {
        auto r = jobs.runPendingJobs(TenantId(t));
        total.add(r);
        if (r.started > 0)
          logServiceEvent("info", "cleansing jobs run", Json([
              "tenant": Json(t), "completed": Json(r.completed), "failed": Json(r.failed)
            ]));
      } catch (Exception e) {
        try
          logServiceEvent("error", "cleansing job worker failed", Json(["tenant": Json(t), "error": Json(e.msg)]));
        catch (Exception) {
        }
      }
    }
    return total;
  }
}
