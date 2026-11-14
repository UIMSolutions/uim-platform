/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Background worker: removes decision log entries older than the retention period.
module uim.platform.authorization.infrastructure.workers.decision_retention;

import vibe.core.core : setTimer, Timer;
import core.time : minutes;
import uim.platform.authorization;

mixin(ShowModule!());

@safe:

class DecisionRetentionWorker {
  protected IQueryDecisions decisions;
  protected string[] tenants;
  protected int retentionDays;
  protected Timer timer;

  this(IQueryDecisions decisions, string[] tenants, int retentionDays) {
    this.decisions = decisions;
    this.tenants = tenants;
    this.retentionDays = retentionDays;
  }

  /// Start periodic pruning (no-op if intervalMinutes or retentionDays is 0).
  void start(uint intervalMinutes) @trusted {
    if (intervalMinutes == 0 || retentionDays <= 0)
      return;
    timer = setTimer(intervalMinutes.minutes, () nothrow {
      try
        runOnce();
      catch (Exception e) {
        try
          logAuthorizationEvent("error", "decision pruning failed", Json(["error": Json(e.msg)]));
        catch (Exception) {
        }
      }
    }, true);
  }

  /// Prune all configured tenants once; returns the number of removed records.
  size_t runOnce() {
    size_t removed;
    foreach (t; tenants)
      removed += decisions.pruneDecisions(TenantId(t), retentionDays);
    if (removed > 0)
      logAuthorizationEvent("info", "decision log pruned", Json([
          "removed": Json(removed), "retentionDays": Json(retentionDays)
        ]));
    return removed;
  }
}
