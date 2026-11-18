/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.ports.driving;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// Bundle of all driving ports. Presentation adapters (REST, OData, CLI, GUI)
/// depend on this bundle only — never on concrete interactors or repositories.
struct ProvisioningPorts {
  IManageSourceSystemsUseCase sourceSystems;
  IManageTargetSystemsUseCase targetSystems;
  IManageProxySystemsUseCase proxySystems;
  IManageTransformationsUseCase transformations;
  IManageProvisioningJobsUseCase jobs;
  IProvisioningLogsQuery logs;
  IProvisionedEntitiesQuery entities;
  ISystemCatalogService catalog;
  IProvisioningStatisticsService statistics;
}
