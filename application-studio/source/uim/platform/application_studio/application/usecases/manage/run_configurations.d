/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.application.usecases.manage.run_configurations;

import uim.platform.application_studio;

// mixin(ShowModule!());

@safe:

class ManageRunConfigurationsUseCase { // TODO: UIMUseCase {
    private RunConfigurationRepository configurations;

    this(RunConfigurationRepository configurations) {
        this.configurations = configurations;
    }

    RunConfiguration getRunConfiguration(TenantId tenantId, RunConfigurationId id) {
        return configurations.findById(tenantId, id);
    }

    RunConfiguration[] listRunConfigurations(TenantId tenantId) {
        return configurations.find(tenantId);
    }

    RunConfiguration[] listRunConfigurations(TenantId tenantId, ProjectId projectId) {
        return configurations.findByProject(tenantId, projectId);
    }

    CommandResult createRunConfiguration(RunConfigurationDTO dto) {
        RunConfiguration e;
        e.initEntity(dto.tenantId, dto.createdBy);

        e.id = dto.configId;
        e.projectId = dto.projectId;
        e.name = dto.name;
        e.description = dto.description;
        e.entryPoint = dto.entryPoint;
        e.arguments = dto.arguments;
        e.environmentVars = dto.environmentVars;
        e.port = dto.port;
        e.debugPort = dto.debugPort;
        if (!StudioValidator.isValidRunConfiguration(e))
            return CommandResult(false, "", "Invalid run configuration data");

        configurations.save(e);
        return CommandResult(true, dto.configId.value, "");
    }

    CommandResult updateRunConfiguration(RunConfigurationDTO dto) {
        auto existing = configurations.findById(dto.tenantId, dto.configId);
        if (existing.isNull)
            return CommandResult(false, "", "Run configuration not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.entryPoint.length > 0) existing.entryPoint = dto.entryPoint;
        if (dto.arguments.length > 0) existing.arguments = dto.arguments;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;
        configurations.update(existing);
        return CommandResult(true, dto.configId.value, "");
    }

    CommandResult deleteRunConfiguration(TenantId tenantId, RunConfigurationId id) {
        auto config = configurations.findById(tenantId, id);
        if (config.isNull)
            return CommandResult(false, "", "Run configuration not found");

        configurations.remove(config);
        return CommandResult(true, config.id.value, "");
    }
}
