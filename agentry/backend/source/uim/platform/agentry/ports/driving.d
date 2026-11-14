/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.ports.driving;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// Bundle of all driving ports. Presentation adapters (HTTP, REST, OData, CLI,
/// GUI) depend on this bundle only — never on concrete use cases or repositories.
struct AgentryPorts {
  IManageMobileApplicationsUseCase mobileApplications;
  IManageAppDefinitionsUseCase appDefinitions;
  IManageAppVersionsUseCase appVersions;
  IManageDevicesUseCase devices;
  IManageSyncSessionsUseCase syncSessions;
  IManageBackendConnectionsUseCase backendConnections;
  IManageDeploymentsUseCase deployments;
  IAgentryStatisticsService statistics;
}
