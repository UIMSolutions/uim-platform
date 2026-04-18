/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.application.usecases.manage.manage_run_configurations;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class ManageRunConfigurationsUseCase : UIMUseCase {
    private RunConfigurationRepository repo;

    this(RunConfigurationRepository repo) {
        this.repo = repo;
    }

    RunConfiguration getById(RunConfigurationId id) {
        return repo.findById(id);
    }

    RunConfiguration[] list() {
        return repo.findAll();
    }

    RunConfiguration[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    RunConfiguration[] listByProject(ProjectId projectId) {
        return repo.findByProject(projectId);
    }

    CommandResult create(RunConfigurationDTO dto) {
        RunConfiguration e;
        e.id = RunConfigurationId(dto.id);
        e.tenantId = dto.tenantId;
        e.projectId = ProjectId(dto.projectId);
        e.name = dto.name;
        e.description = dto.description;
        e.entryPoint = dto.entryPoint;
        e.arguments = dto.arguments;
        e.environmentVars = dto.environmentVars;
        e.port = dto.port;
        e.debugPort = dto.debugPort;
        e.createdBy = dto.createdBy;
        if (!StudioValidator.isValidRunConfiguration(e))
            return CommandResult(false, "", "Invalid run configuration data");
        repo.save(e);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(RunConfigurationDTO dto) {
        if (!repo.existsById(RunConfigurationId(dto.id)))
            return CommandResult(false, "", "Run configuration not found");
        auto existing = repo.findById(RunConfigurationId(dto.id));
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.entryPoint.length > 0) existing.entryPoint = dto.entryPoint;
        if (dto.arguments.length > 0) existing.arguments = dto.arguments;
        if (dto.modifiedBy.length > 0) existing.modifiedBy = dto.modifiedBy;
        repo.update(existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(RunConfigurationId id) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "Run configuration not found");
        repo.remove(id);
        return CommandResult(true, id.value, "");
    }
}
