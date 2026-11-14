/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.ports.repositories.bundle;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// All driven persistence ports, handed to the interactors by the container.
struct StudioRepositories {
  IDevSpaceTypeRepository devSpaceTypes;
  IExtensionRepository extensions;
  IProjectTemplateRepository projectTemplates;
  IDevSpaceRepository devSpaces;
  IProjectRepository projects;
  IServiceBindingRepository serviceBindings;
  IRunConfigurationRepository runConfigurations;
  IBuildConfigurationRepository buildConfigurations;
}
