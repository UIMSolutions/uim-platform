/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Background worker (vibe.d timers, same fiber scheduler as the server):
///   every workerIntervalSeconds     pending deletion requests, due archiving jobs
///   every endOfPurposeCheckSeconds  end-of-purpose check of all application groups (optional)
/// Runs never overlap and never throw.
module uim.platform.data_retention.infrastructure.workers.retention;

import vibe.core.core : setTimer, Timer;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

enum string workerActor = "retention-worker";

class RetentionWorker {
  protected DrPorts ports;
  protected string[] tenants;
  protected Timer jobTimer;
  protected Timer checkTimer;
  protected bool busy;
  size_t runs;
  size_t checks;

  this(DrPorts ports, string[] tenants) {
    this.ports = ports;
    this.tenants = tenants;
  }

  /// Start the periodic runs (0 = disabled).
  void start(uint intervalSeconds, uint checkSeconds) @trusted {
    if (tenants.length == 0)
      return;
    if (intervalSeconds > 0)
      jobTimer = setTimer(dur!"seconds"(intervalSeconds), () @safe nothrow { runOnce(); }, true);
    if (checkSeconds > 0)
      checkTimer = setTimer(dur!"seconds"(checkSeconds), () @safe nothrow { checkOnce(); }, true);
  }

  /// Pending deletion requests and due archiving jobs of all tenants.
  RunSummary runOnce() nothrow {
    RunSummary total;
    if (busy)
      return total;
    busy = true;
    scope (exit)
      busy = false;
    runs++;
    foreach (t; tenants) {
      try {
        auto requests = ports.deletionRequests.processPending(TenantId(t), UserId(workerActor));
        auto jobs = ports.archivingJobs.runDue(TenantId(t), UserId(workerActor));
        total.add(requests);
        total.add(jobs);
        if (requests.started + jobs.started > 0)
          logServiceEvent("info", "retention worker run", Json([
              "tenant": Json(t), "requests": Json(requests.started), "rejected": Json(requests.rejected),
              "jobs": Json(jobs.started), "failed": Json(requests.failed + jobs.failed)
            ]));
      } catch (Exception e)
        report(t, e.msg);
    }
    return total;
  }

  /// End-of-purpose check of every application group of all tenants.
  void checkOnce() nothrow {
    if (busy)
      return;
    busy = true;
    scope (exit)
      busy = false;
    checks++;
    foreach (t; tenants) {
      try {
        EndOfPurposeCheckRequest r;
        r.tenantId = TenantId(t);
        r.actor = UserId(workerActor);
        auto result = ports.checks.checkEndOfPurpose(r);
        logServiceEvent("info", "end-of-purpose check", Json([
            "tenant": Json(t), "checked": Json(result.checked), "blocked": Json(result.blocked),
            "markedForDeletion": Json(result.markedForDeletion), "legalHolds": Json(result.legalHolds)
          ]));
      } catch (Exception e)
        report(t, e.msg);
    }
  }

  protected void report(string tenant, string message) nothrow {
    try
      logServiceEvent("error", "retention worker failed", Json(["tenant": Json(tenant), "error": Json(message)]));
    catch (Exception) {
    }
  }
}
