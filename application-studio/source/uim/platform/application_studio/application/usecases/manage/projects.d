/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.application.usecases.manage.projects;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class ManageProjectsUseCase { // TODO: UIMUseCase {
    private ProjectRepository repo;

    this(ProjectRepository repo) {
        this.repo = repo;
    }

    Project getById(ProjectId id) {
        return repo.findById(id);
    }

    Project[] list() {
        return repo.findAll();
    }

    Project[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Project[] listByDevSpace(DevSpaceId devSpaceId) {
        return repo.findByDevSpace(devSpaceId);
    }

    CommandResult create(ProjectDTO dto) {
        Project e;
        e.id = ProjectId(dto.id);
        e.tenantId = dto.tenantId;
        e.devSpaceId = DevSpaceId(dto.devSpaceId);
        e.name = dto.name;
        e.description = dto.description;
        e.templateId = ProjectTemplateId(dto.templateId);
        e.rootPath = dto.rootPath;
        e.gitRepositoryUrl = dto.gitRepositoryUrl;
        e.gitBranch = dto.gitBranch;
        e.namespace_ = dto.namespace_;
        e.createdBy = dto.createdBy;
        if (!StudioValidator.isValidProject(e))
            return CommandResult(false, "", "Invalid project data");
        repo.save(e);
        return CommandResult(true, dto.id.value, "");
    }

    CommandResult update(ProjectDTO dto) {
        if (!repo.existsById(ProjectId(dto.id)))
            return CommandResult(false, "", "Project not found");
        auto existing = repo.findById(ProjectId(dto.id));
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.gitRepositoryUrl.length > 0) existing.gitRepositoryUrl = dto.gitRepositoryUrl;
        if (dto.gitBranch.length > 0) existing.gitBranch = dto.gitBranch;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, dto.id.value, "");
    }

    CommandResult remove(ProjectId id) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "Project not found");
        repo.removeById(id);
        return CommandResult(true, id.value, "");
    }
}
