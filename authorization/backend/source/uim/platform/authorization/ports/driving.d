/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The complete set of driving ports — everything an adapter (JSON API,
/// REST, OData, Diet dashboard, CLI, GUI, workers) is allowed to call.
module uim.platform.authorization.ports.driving;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

struct AuthorizationPorts {
  IManageApplications applications;
  IManageApplicationApis apis;
  IManagePolicies policies;
  IManageAssignments assignments;
  IEvaluateAuthorization evaluation;
  IQueryDecisions decisions;
  IAuthorizationStatistics statistics;
  IDemoDataService demoData;
}
