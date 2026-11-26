/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The complete set of driving ports — what every adapter (REST, OData,
/// CLI, GUI, workers) may call.
module uim.platform.application_autoscaler.ports.driving;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

struct AasPorts {
  IManageBindings bindings;
  IManagePolicies policies;
  IManageRules rules;
  IManageSchedules schedules;
  IManageMetrics metrics;
  IScalingEngine scaling;
  IAasStatisticsService statistics;
  IAuthenticate authentication;
  IManageUsers users;
}
