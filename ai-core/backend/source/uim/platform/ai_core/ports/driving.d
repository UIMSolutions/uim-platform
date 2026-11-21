/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The complete set of driving ports — what every adapter (AI API, OData,
/// CLI, GUI, workers) may call.
module uim.platform.ai_core.ports.driving;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

struct AiCorePorts {
  IManageResourceGroups resourceGroups;
  IManageScenarios scenarios;
  IManageExecutables executables;
  IManageConfigurations configurations;
  IManageExecutions executions;
  IManageDeployments deployments;
  IManageArtifacts artifacts;
  IManageSchedules schedules;
  IManageMetrics metrics;
  IManageSecrets secrets;
  IReconcileLifecycle reconciler;
  IAiCoreStatisticsService statistics;
}
