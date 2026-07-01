/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.infrastructure.persistence.memory.project_members;

import uim.platform.build_apps;

// mixin(ShowModule!());

@safe:

class MemoryProjectMemberRepository : TenantRepository!(ProjectMember, ProjectMemberId), ProjectMemberRepository {

    size_t countByApplication(TenantId tenantId, ApplicationId applicationId) {
        return findByApplication(tenantId, applicationId).length;
    }

    ProjectMember[] filterByApplication(ProjectMember[] members, ApplicationId applicationId) {
        return members.filter!(e => e.applicationId == applicationId).array;
    }

    ProjectMember[] findByApplication(TenantId tenantId, ApplicationId applicationId) {
        return filterByApplication(findByTenant(tenantId), applicationId);
    }

    void removeByApplication(TenantId tenantId, ApplicationId applicationId) {
        findByApplication(tenantId, applicationId).each!(e => remove(e));
    }

     size_t countByRole(TenantId tenantId, MemberRole role) {
        return findByRole(tenantId, role).length;
    }

    ProjectMember[] filterByRole(ProjectMember[] members, MemberRole role) {
        return members.filter!(e => e.role == role).array;
    }

    ProjectMember[] findByRole(TenantId tenantId, MemberRole role) {
        return filterByRole(findByTenant(tenantId), role);
    }

    void removeByRole(TenantId tenantId, MemberRole role) {
        findByRole(tenantId, role).each!(e => remove(e));
    }

     size_t countByUser(TenantId tenantId, UserId userId) {
        return findByUser(tenantId, userId).length;
    }

    ProjectMember[] filterByUser(ProjectMember[] members, UserId userId) {
        return members.filter!(e => e.userId == userId).array;
    }

    ProjectMember[] findByUser(TenantId tenantId, UserId userId) {
        return filterByUser(findByTenant(tenantId), userId);
    }

    void removeByUser(TenantId tenantId, UserId userId) {
        findByUser(tenantId, userId).each!(e => remove(e));
    }

}
