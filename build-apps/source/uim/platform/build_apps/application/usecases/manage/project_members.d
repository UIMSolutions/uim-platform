/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.application.usecases.manage.project_members;

import uim.platform.build_apps;

mixin(ShowModule!());

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

    ProjectMember[] listByApplication(TenantId tenantId, ApplicationId applicationId) {
        return repo.findByApplication(tenantId, applicationId);
    }

    CommandResult createProjectMember(ProjectMemberDTO dto) {
        auto member = ProjectMember(dto.tenantId, dto.memberId.isNull ? ProjectMemberId(createId()) : dto.memberId, dto.createdBy);
        member.applicationId = dto.applicationId;
        member.userId = dto.userId;
        member.displayName = dto.displayName;
        member.email = dto.email;
        member.role = toMemberRole(dto.role);
        member.permissions = dto.permissions;

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

///
unittest {
    auto repo = new ProjectMemberRepository();
    auto usecase = new ManageProjectMembersUseCase(repo);
    auto tenantId = TenantId("test-tenant");

    // Test create
    ProjectMemberDTO createDto;
    createDto.tenantId = tenantId;
    createDto.memberId = ProjectMemberId("projectMember-1");
    createDto.displayName = "Test ProjectMember";
    auto createResult = usecase.createProjectMember(createDto);
    // TODO: assert(createResult.success, createResult.message);

    // Test list
    auto items = usecase.listProjectMembers(tenantId);
    // TODO: assert(items.length == 1);

    // Test get
    auto item = usecase.getProjectMember(tenantId, ProjectMemberId("projectMember-1"));
    // TODO: assert(!item.isNull);

    // Test update
    ProjectMemberDTO updateDto;
    updateDto.tenantId = tenantId;
    updateDto.memberId = ProjectMemberId("projectMember-1");
    updateDto.displayName = "Updated ProjectMember";
    auto updateResult = usecase.updateProjectMember(updateDto);
    // TODO: assert(updateResult.success, updateResult.message);

    // Test delete
    auto deleteResult = usecase.deleteProjectMember(tenantId, ProjectMemberId("projectMember-1"));
    // TODO: assert(deleteResult.success, deleteResult.message);
    // TODO: assert(usecase.listProjectMembers(tenantId).length == 0);

}
