/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.domain.repositories.team_members;

import uim.platform.responsibility;

// mixin(ShowModule!());

@safe:

interface TeamMemberRepository : ITenantRepository!(TeamMember, TeamMemberId) {
    TeamMember[] findByTeam(TenantId tenantId, string teamId);
    TeamMember[] findByUser(TenantId tenantId, string userId);
    TeamMember[] findByFunction(TenantId tenantId, string functionId);
    TeamMember[] findByRole(TenantId tenantId, MemberRole role);
}
