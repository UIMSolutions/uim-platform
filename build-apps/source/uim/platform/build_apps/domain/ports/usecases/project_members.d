/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.domain.ports.usecases.project_members;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

interface IManageProjectMembersUseCase {
    
    ProjectMember getProjectMember(TenantId tenantId, ProjectMemberId id);
    ProjectMember[] listProjectMembers(TenantId tenantId);
    ProjectMember[] listByApplication(TenantId tenantId, ApplicationId applicationId);
    UsecaseResult createProjectMember(ProjectMemberDTO dto);
    UsecaseResult updateProjectMember(ProjectMemberDTO dto);
    UsecaseResult deleteProjectMember(TenantId tenantId, ProjectMemberId id);
    
}
