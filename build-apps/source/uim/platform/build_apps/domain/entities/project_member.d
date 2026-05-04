/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.domain.entities.project_member;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

struct ProjectMember {
    ProjectMemberId id;
    TenantId tenantId;
    ApplicationId applicationId;
    string userId;
    string displayName;
    string email;
    MemberRole role = MemberRole.viewer;
    MemberStatus status = MemberStatus.invited;
    string permissions;
    string invitedAt;
    string joinedAt;
    long createdAt;
    long updatedAt;
    UserId createdBy;
    UserId updatedBy;

    Json projectMemberToJson() {
        return Json.emptyObject
            .set("id", id)
            .set("tenantId", tenantId)
            .set("applicationId", applicationId)
            .set("userId", userId)
            .set("displayName", displayName)
            .set("email", email)
            .set("role", role.to!string)
            .set("status", status.to!string)
            .set("permissions", permissions)
            .set("invitedAt", invitedAt)
            .set("joinedAt", joinedAt)
            .set("createdAt", createdAt)
            .set("updatedAt", updatedAt)
            .set("createdBy", createdBy)
            .set("updatedBy", updatedBy);
    }
}
