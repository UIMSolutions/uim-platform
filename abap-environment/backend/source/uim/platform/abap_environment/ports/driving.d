/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.ports.driving;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// Bundle of all driving ports. Presentation adapters (REST, OData, CLI, GUI)
/// depend on this bundle only — never on concrete interactors or repositories.
struct AbapPorts {
  IManageSystemsUseCase systems;
  IManageSoftwareComponentsUseCase softwareComponents;
  IManageCommunicationArrangementsUseCase communicationArrangements;
  IManageServiceBindingsUseCase serviceBindings;
  IManageBusinessUsersUseCase businessUsers;
  IManageBusinessRolesUseCase businessRoles;
  IManageTransportRequestsUseCase transportRequests;
  IManageApplicationJobsUseCase applicationJobs;
  IReconcileUseCase reconciler;
  IAbapStatisticsService statistics;
}
