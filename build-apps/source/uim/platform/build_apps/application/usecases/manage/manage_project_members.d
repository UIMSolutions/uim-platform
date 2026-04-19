/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.application.usecases.manage.manage_project_members;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class ManageProjectMembersUseCase : UIMUseCase {
    private ProjectMemberRepository repo;

    this(ProjectMemberRepository repo) {
        this.repo = repo;
    }

    ProjectMember getById(ProjectMemberId id) {
        return repo.findById(id);
    }

    ProjectMember[] list() {
        return repo.findAll();
    }

    ProjectMember[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    ProjectMember[] listByApplication(ApplicationId applicationId) {
        return repo.findByApplication(applicationId);
    }

    CommandResult create(ProjectMemberDTO dto) {
        ProjectMember e;
        e.id = ProjectMemberId(dto.id);
        e.tenantId = dto.tenantId;
        e.applicationId = ApplicationId(dto.applicationId);
        e.userId = dto.userId;
        e.displayName = dto.displayName;
        e.email = dto.email;
        e.permissions = dto.permissions;
        e.createdBy = dto.createdBy;
        if (!BuildAppsValidator.isValidProjectMember(e))
            return CommandResult(false, "", "Invalid project member data");
        repo.save(e);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(ProjectMemberDTO dto) {
        if (!repo.existsById(ProjectMemberId(dto.id)))
            return CommandResult(false, "", "Project member not found");
        auto existing = repo.findById(ProjectMemberId(dto.id));
        if (dto.displayName.length > 0) existing.displayName = dto.displayName;
        if (dto.email.length > 0) existing.email = dto.email;
        if (dto.permissions.length > 0) existing.permissions = dto.permissions;
        if (dto.modifiedBy.length > 0) existing.modifiedBy = dto.modifiedBy;
        repo.update(existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(ProjectMemberId id) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "Project member not found");
        repo.remove(id);
        return CommandResult(true, id.value, "");
    }
}
