/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.ports.driving;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Bundle of all driving ports. Presentation adapters (REST, OData, CLI, GUI)
/// depend on this bundle only — never on concrete interactors or repositories.
struct StudioPorts {
  IManageDevSpaceTypesUseCase devSpaceTypes;
  IManageExtensionsUseCase extensions;
  IManageProjectTemplatesUseCase projectTemplates;
  IManageDevSpacesUseCase devSpaces;
  IManageProjectsUseCase projects;
  IManageServiceBindingsUseCase serviceBindings;
  IManageRunConfigurationsUseCase runConfigurations;
  IManageBuildConfigurationsUseCase buildConfigurations;
  IReconcileUseCase reconciler;
  IStudioStatisticsService statistics;
  IStudioCatalogService catalog;
}
