/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The execution log: monitoring and housekeeping.
module uim.platform.integration_automation.application.usecases.monitoring;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

class MonitorExecutionsUseCase : IaInteractor, IMonitorExecutions {
  this(IaRepositories repos, IClock clock, IIaEventPublisher events, IIaUnitOfWork unitOfWork, IaPolicy policy) {
    super(repos, clock, events, unitOfWork, policy);
  }

  ExecutionLog[] list(TenantId t) {
    return repos.executionLogs.findAll(t);
  }

  ExecutionLog get(TenantId t, ExecutionLogId id) {
    return required(repos.executionLogs.findById(t, id), "Execution log entry '" ~ id.value ~ "'");
  }

  ExecutionLog[] listOf(TenantId t, WorkflowId workflow) {
    return repos.executionLogs.findByReference(t, "workflowId", workflow.value);
  }

  long purge(TenantId t, int olderThanDays, UserId actor) {
    requireRange(olderThanDays, 1, 36_500, "Days");
    auto limit = plusDays(now, -olderThanDays);
    long removed;
    batch(() {
      foreach (l; repos.executionLogs.findAll(t))
        if (l.createdAt < limit && repos.executionLogs.removeById(t, l.id))
          removed++;
    });
    emit("executionLogs.purged", t, "", Json(["removed": Json(removed), "olderThanDays": Json(olderThanDays),
        "by": Json(actor.value)]));
    return removed;
  }
}
