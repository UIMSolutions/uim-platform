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
    private Projectprojectssitory projects;

    this(Projectprojectssitory projects) {
        this.projects = projects;
    }

    Project getById(ProjectId id) {
        return projects.findById(tenantId, id);
    }

    Project[] listProjects(TenantId tenantId) {
        return projects.findByTenant(tenantId);
    }

    Project[] listProjects(DevSpaceId devSpaceId) {
        return projects.findByDevSpace(devSpaceId);
    }

    CommandResult createProject(ProjectDTO dto) {
        Project e;
        
        e.id = ProjectId(dto.id);
        e.tenantId = dto.tenantId;
        e.devSpaceId = DevSpaceId(dto.devSpaceId);
        e.name = dto.name;
        e.description = dto.description;
        e.templateId = ProjectTemplateId(dto.templateId);
        e.rootPath = dto.rootPath;
        e.gitprojectssitoryUrl = dto.gitprojectssitoryUrl;
        e.gitBranch = dto.gitBranch;
        e.namespace_ = dto.namespace_;
        e.createdBy = dto.createdBy;
        if (!StudioValidator.isValidProject(e))
            return CommandResult(false, "", "Invalid project data");

        projects.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult updateProject(ProjectDTO dto) {
        auto existing = projects.findById(ProjectId(dto.id));
        if (existing.isNull)
            return CommandResult(false, "", "Project not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.gitprojectssitoryUrl.length > 0) existing.gitprojectssitoryUrl = dto.gitprojectssitoryUrl;
        if (dto.gitBranch.length > 0) existing.gitBranch = dto.gitBranch;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        projects.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteProject(TenantId tenantId, ProjectId id) {
        auto project = projects.findById(tenantId, id);
        if (project.isNull)
            return CommandResult(false, "", "Project not found");

        projects.remove(project);
        return CommandResult(true, project.id.value, "");
    }
}
