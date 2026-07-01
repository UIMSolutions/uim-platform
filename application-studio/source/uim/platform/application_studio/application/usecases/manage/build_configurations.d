/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.application.usecases.manage.build_configurations;

import uim.platform.application_studio;

// mixin(ShowModule!());

@safe:

class ManageBuildConfigurationsUseCase { // TODO: UIMUseCase {
    private BuildConfigurationRepository configurations;

    this(BuildConfigurationRepository configurations) {
        this.configurations = configurations;
    }

    BuildConfiguration getBuildConfiguration(TenantId tenantId, BuildConfigurationId id) {
        return configurations.findById(tenantId, id);
    }

    BuildConfiguration[] listBuildConfigurations(TenantId tenantId) {
        return configurations.findByTenant(tenantId);
    }

    BuildConfiguration[] listBuildConfigurations(TenantId tenantId, ProjectId projectId) {
        return configurations.findByProject(tenantId, projectId);
    }

    CommandResult createBuildConfiguration(BuildConfigurationDTO dto) {
        auto e = BuildConfiguration(dto.tenantId, dto.configId.isNull ? BuildConfigurationId(createId()) : dto.configId, dto.createdBy);
        e.projectId = dto.projectId;
        e.name = dto.name;
        e.description = dto.description;
        e.buildCommand = dto.buildCommand;
        e.deployCommand = dto.deployCommand;
        e.artifactPath = dto.artifactPath;
        e.mtaDescriptor = dto.mtaDescriptor;
        if (!StudioValidator.isValidBuildConfiguration(e))
            return CommandResult(false, "", "Invalid build configuration data");

        configurations.save(e);
        return CommandResult(true, dto.configId.value, "");
    }

    CommandResult updateBuildConfiguration(BuildConfigurationDTO dto) {
        auto existing = configurations.findById(dto.tenantId, dto.configId);
        if (existing.isNull)
            return CommandResult(false, "", "Build configuration not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.buildCommand.length > 0) existing.buildCommand = dto.buildCommand;
        if (dto.deployCommand.length > 0) existing.deployCommand = dto.deployCommand;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        configurations.update(existing);
        return CommandResult(true, dto.configId.value, "");
    }

    CommandResult deleteBuildConfiguration(TenantId tenantId, BuildConfigurationId id) {
        auto config = configurations.findById(tenantId, id);
        if (config.isNull)
            return CommandResult(false, "", "Build configuration not found");

        configurations.remove(config);
        return CommandResult(true, config.id.value, "");
    }
}
