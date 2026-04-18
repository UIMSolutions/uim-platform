/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.application.usecases.manage.manage_build_configurations;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class ManageBuildConfigurationsUseCase : UIMUseCase {
    private BuildConfigurationRepository repo;

    this(BuildConfigurationRepository repo) {
        this.repo = repo;
    }

    BuildConfiguration getById(BuildConfigurationId id) {
        return repo.findById(id);
    }

    BuildConfiguration[] list() {
        return repo.findAll();
    }

    BuildConfiguration[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    BuildConfiguration[] listByProject(ProjectId projectId) {
        return repo.findByProject(projectId);
    }

    CommandResult create(BuildConfigurationDTO dto) {
        BuildConfiguration e;
        e.id = BuildConfigurationId(dto.id);
        e.tenantId = dto.tenantId;
        e.projectId = ProjectId(dto.projectId);
        e.name = dto.name;
        e.description = dto.description;
        e.buildCommand = dto.buildCommand;
        e.deployCommand = dto.deployCommand;
        e.artifactPath = dto.artifactPath;
        e.mtaDescriptor = dto.mtaDescriptor;
        e.createdBy = dto.createdBy;
        if (!StudioValidator.isValidBuildConfiguration(e))
            return CommandResult(false, "", "Invalid build configuration data");
        repo.save(e);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(BuildConfigurationDTO dto) {
        if (!repo.existsById(BuildConfigurationId(dto.id)))
            return CommandResult(false, "", "Build configuration not found");
        auto existing = repo.findById(BuildConfigurationId(dto.id));
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.buildCommand.length > 0) existing.buildCommand = dto.buildCommand;
        if (dto.deployCommand.length > 0) existing.deployCommand = dto.deployCommand;
        if (dto.modifiedBy.length > 0) existing.modifiedBy = dto.modifiedBy;
        repo.update(existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(BuildConfigurationId id) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "Build configuration not found");
        repo.remove(id);
        return CommandResult(true, id.value, "");
    }
}
