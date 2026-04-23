/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.infrastructure.persistence.memory.project_members;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class MemoryProjectMemberRepository : TenantRepository!(ProjectMember, ProjectMemberId), ProjectMemberRepository {

    size_t countByApplication(ApplicationId applicationId) {
        return findByApplication(applicationId).length;
    }

    ProjectMember[] findByApplication(ApplicationId applicationId) {
        return findAll.filter!(e => e.applicationId == applicationId).array;
    }

    void removeByApplication(ApplicationId applicationId) {
        findByApplication(applicationId).each!(e => remove(e));
    }

     size_t countByRole(MemberRole role) {
        return findByRole(role).length;
    }

    ProjectMember[] findByRole(MemberRole role) {
        return findAll.filter!(e => e.role == role).array;
    }

    void removeByRole(MemberRole role) {
        findByRole(role).each!(e => remove(e));
    }

     size_t countByUserId(string userId) {
        return findByUserId(userId).length;
    }

    ProjectMember[] findByUserId(string userId) {
        return findAll.filter!(e => e.userId == userId).array;
    }

    void removeByUserId(string userId) {
        findByUserId(userId).each!(e => remove(e));
    }

}
