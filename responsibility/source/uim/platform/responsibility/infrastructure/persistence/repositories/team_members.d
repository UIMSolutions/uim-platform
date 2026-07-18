/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.infrastructure.persistence.repositories.team_members;

import uim.platform.responsibility;

mixin(ShowModule!());

@safe:

class MemoryTeamMemberRepository
    : TenantRepository!(TeamMember, TeamMemberId),
      TeamMemberRepository {

    TeamMember[] findByTeam(TenantId tenantId, string teamId) {
        return findByTenant(tenantId).filter!(m => m.teamId == teamId).array;
    }

    TeamMember[] findByUser(TenantId tenantId, string userId) {
        return findByTenant(tenantId).filter!(m => m.userId == userId).array;
    }

    TeamMember[] findByFunction(TenantId tenantId, string functionId) {
        return findByTenant(tenantId).filter!(m => m.functionId == functionId).array;
    }

    TeamMember[] findByRole(TenantId tenantId, MemberRole role) {
        return findByTenant(tenantId).filter!(m => m.role == role).array;
    }
}
