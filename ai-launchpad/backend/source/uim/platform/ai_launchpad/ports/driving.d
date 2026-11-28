/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The complete set of driving ports — what every adapter (REST, OData,
/// CLI, GUI, the reconcile worker) may call.
module uim.platform.ai_launchpad.ports.driving;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

struct AilpPorts {
  // runtimes
  IManageWorkspaces workspaces;
  IManageConnections connections;
  IManageResourceGroups resourceGroups;
  // ML life cycle
  IManageScenarios scenarios;
  IManageConfigurations configurations;
  IManageExecutions executions;
  IManageDeployments deployments;
  IReconcileRuntime reconciler;
  // registry
  IManageModels models;
  IManageDatasets datasets;
  // generative AI hub
  IManagePromptCollections promptCollections;
  IManagePrompts prompts;
  // launchpad and administration
  IManageTiles tiles;
  IAuthenticate authentication;
  IManageUsers users;
  IManageRoles roles;
  IAuditLog auditLog;
  IAilpStatisticsService statistics;
}
