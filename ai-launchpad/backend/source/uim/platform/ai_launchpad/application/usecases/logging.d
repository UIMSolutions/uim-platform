/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The audit log of the administration: newest first, read only; entries
/// older than the retention (logRetentionDays) are purged on demand and by
/// the housekeeping worker.
module uim.platform.ai_launchpad.application.usecases.logging;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

class AuditLogUseCase : AilpInteractor, IAuditLog {
  this(AilpRepositories repos, IClock clock, IAuditTrail audit, IAilpUnitOfWork unitOfWork, AilpPolicy policy) {
    super(repos, clock, audit, unitOfWork, policy);
  }

  LogEntry[] list(TenantId t) {
    auto entries = repos.logs.findAll(t);
    entries.reverse();
    return entries;
  }

  LogEntry get(TenantId t, LogEntryId id) {
    return required(repos.logs.findById(t, id), "Log entry '" ~ id.value ~ "'");
  }

  PurgeResult purge(TenantId t, UserId actor) {
    PurgeResult r;
    batch(() { r.entries = repos.logs.removeBefore(t, plusDays(now, -policy.logRetentionDays)); });
    if (r.entries > 0)
      emit("log.purged", t, actor, t.value, Json([
          "entries": Json(r.entries), "retentionDays": Json(policy.logRetentionDays)
        ]));
    return r;
  }
}
