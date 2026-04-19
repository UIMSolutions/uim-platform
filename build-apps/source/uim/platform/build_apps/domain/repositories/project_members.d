/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.domain.repositories.project_members;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

interface ProjectMemberRepository {
    bool existsById(ProjectMemberId id);
    ProjectMember findById(ProjectMemberId id);

    ProjectMember[] findAll();
    ProjectMember[] findByTenant(TenantId tenantId);
    ProjectMember[] findByApplication(ApplicationId applicationId);
    ProjectMember[] findByUserId(string userId);

    void save(ProjectMember entity);
    void update(ProjectMember entity);
    void remove(ProjectMemberId id);
}
