/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.domain.repositories.project_members;

import uim.platform.build_apps;

// mixin(ShowModule!());

@safe:

interface ProjectMemberRepository : ITenantRepository!(ProjectMember, ProjectMemberId) {

    size_t countByApplication(TenantId tenantId, ApplicationId applicationId);
    ProjectMember[] findByApplication(TenantId tenantId, ApplicationId applicationId);
    void removeByApplication(TenantId tenantId, ApplicationId applicationId);

    size_t countByUser(TenantId tenantId, UserId userId);
    ProjectMember[] findByUser(TenantId tenantId, UserId userId);
    void removeByUser(TenantId tenantId, UserId userId);

}
