/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.application.usecases.manage.project_members;

import uim.platform.build_apps;

// mixin(ShowModule!());

@safe:

class ManageProjectMembersUseCase { // TODO: UIMUseCase {
    private ProjectMemberRepository repo;

    this(ProjectMemberRepository repo) {
        this.repo = repo;
    }

    ProjectMember getProjectMember(TenantId tenantId, ProjectMemberId id) {
        return repo.findById(tenantId, id);
    }

    ProjectMember[] listProjectMembers(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    ProjectMember[] listByApplication(ApplicationId applicationId) {
        return repo.findByApplication(applicationId);
    }

    CommandResult createProjectMember(ProjectMemberDTO dto) {
        auto member = ProjectMember(dto.tenantId);
        member.id = dto.memberId;
        member.applicationId = dto.applicationId;
        member.userId = dto.userId;
        member.displayName = dto.displayName;
        member.email = dto.email;
        member.role = toMemberRole(dto.role);
        member.permissions = dto.permissions;
        member.createdBy = dto.createdBy;

        if (!BuildAppsValidator.isValidProjectMember(member))
            return CommandResult(false, "", "Invalid project member data");

        repo.save(member);
        return CommandResult(true, member.id.value, "");
    }

    CommandResult updateProjectMember(ProjectMemberDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.memberId);
        if (existing.isNull)
            return CommandResult(false, "", "Project member not found");

        if (dto.displayName.length > 0) existing.displayName = dto.displayName;
        if (dto.email.length > 0) existing.email = dto.email;
        if (dto.permissions.length > 0) existing.permissions = dto.permissions;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;
        
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteProjectMember(TenantId tenantId, ProjectMemberId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return CommandResult(false, "", "Project member not found");
            
        repo.remove(entity);
        return CommandResult(true, entity.id.value, "");
    }
}
