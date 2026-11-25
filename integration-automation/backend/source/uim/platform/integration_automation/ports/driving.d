/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The complete set of driving ports — what every adapter (REST, OData,
/// CLI, GUI, workers) may call.
module uim.platform.integration_automation.ports.driving;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

struct IaPorts {
  IManageSystems systems;
  IManageDestinations destinations;
  IManageScenarios scenarios;
  IManageScenarioTasks scenarioTasks;
  IManageWorkflows workflows;
  IProcessTasks tasks;
  IMonitorExecutions executions;
  IIaStatisticsService statistics;
  IAuthenticate authentication;
  IManageUsers users;
}
