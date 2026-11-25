/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving port of the execution log.
module uim.platform.integration_automation.ports.usecases.monitoring;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

interface IMonitorExecutions {
  ExecutionLog[] list(TenantId t);
  ExecutionLog get(TenantId t, ExecutionLogId id);
  ExecutionLog[] listOf(TenantId t, WorkflowId workflow);
  /// Remove entries older than the given days; returns the number removed.
  long purge(TenantId t, int olderThanDays, UserId actor);
}
