/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The complete set of driving ports — what every adapter (REST, OData,
/// CLI, GUI, the scheduler worker) may call.
module uim.platform.datasphere.ports.driving;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

struct DspPorts {
  IManageSpaces spaces;
  IManageMembers members;
  IManageConnections connections;
  IManageRemoteTables remoteTables;
  IManageViews views;
  IManageDataFlows dataFlows;
  IManageTasks tasks;
  IManageTaskChains taskChains;
  IMonitorRuns monitor;
  IManageAccessControls accessControls;
  IManageCatalog catalog;
  IDspStatisticsService statistics;
  IAuthenticate authentication;
  IManageUsers users;
}
