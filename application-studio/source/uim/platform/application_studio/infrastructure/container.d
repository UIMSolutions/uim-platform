/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.infrastructure.container;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

struct Container {
    ManageDevSpacesUseCase manageDevSpacesUseCase;
    ManageDevSpaceTypesUseCase manageDevSpaceTypesUseCase;
    ManageExtensionsUseCase manageExtensionsUseCase;
    ManageProjectsUseCase manageProjectsUseCase;
    ManageProjectTemplatesUseCase manageProjectTemplatesUseCase;
    ManageServiceBindingsUseCase manageServiceBindingsUseCase;
    ManageRunConfigurationsUseCase manageRunConfigurationsUseCase;
    ManageBuildConfigurationsUseCase manageBuildConfigurationsUseCase;

    DevSpaceController devSpaceController;
    DevSpaceTypeController devSpaceTypeController;
    ExtensionController extensionController;
    ProjectController projectController;
    ProjectTemplateController projectTemplateController;
    ServiceBindingController serviceBindingController;
    RunConfigurationController runConfigurationController;
    BuildConfigurationController buildConfigurationController;
    HealthController healthController;
}

Container buildContainer(AppConfig config) {
    Container c;

    // Repositories
    auto devSpaceRepo = new MemoryDevSpaceRepository();
    auto devSpaceTypeRepo = new MemoryDevSpaceTypeRepository();
    auto extensionRepo = new MemoryExtensionRepository();
    auto projectRepo = new MemoryProjectRepository();
    auto projectTemplateRepo = new MemoryProjectTemplateRepository();
    auto serviceBindingRepo = new MemoryServiceBindingRepository();
    auto runConfigurationRepo = new MemoryRunConfigurationRepository();
    auto buildConfigurationRepo = new MemoryBuildConfigurationRepository();

    // Use Cases
    c.manageDevSpacesUseCase = new ManageDevSpacesUseCase(devSpaceRepo);
    c.manageDevSpaceTypesUseCase = new ManageDevSpaceTypesUseCase(devSpaceTypeRepo);
    c.manageExtensionsUseCase = new ManageExtensionsUseCase(extensionRepo);
    c.manageProjectsUseCase = new ManageProjectsUseCase(projectRepo);
    c.manageProjectTemplatesUseCase = new ManageProjectTemplatesUseCase(projectTemplateRepo);
    c.manageServiceBindingsUseCase = new ManageServiceBindingsUseCase(serviceBindingRepo);
    c.manageRunConfigurationsUseCase = new ManageRunConfigurationsUseCase(runConfigurationRepo);
    c.manageBuildConfigurationsUseCase = new ManageBuildConfigurationsUseCase(buildConfigurationRepo);

    // Controllers
    c.devSpaceController = new DevSpaceController(c.manageDevSpacesUseCase);
    c.devSpaceTypeController = new DevSpaceTypeController(c.manageDevSpaceTypesUseCase);
    c.extensionController = new ExtensionController(c.manageExtensionsUseCase);
    c.projectController = new ProjectController(c.manageProjectsUseCase);
    c.projectTemplateController = new ProjectTemplateController(c.manageProjectTemplatesUseCase);
    c.serviceBindingController = new ServiceBindingController(c.manageServiceBindingsUseCase);
    c.runConfigurationController = new RunConfigurationController(c.manageRunConfigurationsUseCase);
    c.buildConfigurationController = new BuildConfigurationController(c.manageBuildConfigurationsUseCase);
    c.healthController = new HealthController();

    return c;
}
