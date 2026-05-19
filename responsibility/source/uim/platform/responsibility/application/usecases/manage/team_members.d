/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.application.usecases.manage.team_members;

import uim.platform.responsibility;

mixin(ShowModule!());

@safe:

class ManageTeamMembersUseCase {
    private TeamMemberRepository repo;

    this(TeamMemberRepository repo) { this.repo = repo; }

    TeamMember getMember(TenantId tenantId, TeamMemberId id) {
        return repo.findById(tenantId, id);
    }

    TeamMember[] listMembers(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    TeamMember[] listMembersByTeam(TenantId tenantId, string teamId) {
        return repo.findByTeam(tenantId, teamId);
    }

    CommandResult addMember(TeamMemberDTO dto) {
        TeamMember m;
        m.initEntity(dto.tenantId, dto.createdBy);
        m.id          = dto.memberId;
        m.teamId      = dto.teamId;
        m.userId      = dto.userId;
        m.email       = dto.email;
        m.displayName = dto.displayName;
        m.functionId  = dto.functionId;
        m.role        = parseRole(dto.role);
        m.validFrom   = dto.validFrom;
        m.validTo     = dto.validTo;
        if (m.userId.length == 0)
            return CommandResult(false, "", "userId is required");
        if (m.teamId.length == 0)
            return CommandResult(false, "", "teamId is required");
        repo.save(m);
        return CommandResult(true, m.id.value, "");
    }

    CommandResult updateMember(TeamMemberDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.memberId);
        if (existing.isNull)
            return CommandResult(false, "", "Team member not found");
        if (dto.functionId.length > 0)  existing.functionId  = dto.functionId;
        if (dto.displayName.length > 0) existing.displayName = dto.displayName;
        if (dto.email.length > 0)       existing.email       = dto.email;
        if (dto.validTo > 0)            existing.validTo     = dto.validTo;
        if (!dto.updatedBy.isNull)      existing.updatedBy   = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult removeMember(TenantId tenantId, TeamMemberId id) {
        auto e = repo.findById(tenantId, id);
        if (e.isNull)
            return CommandResult(false, "", "Team member not found");
        repo.remove(e);
        return CommandResult(true, e.id.value, "");
    }

    private static MemberRole parseRole(string s) {
        import std.conv : to;
        try { return s.to!MemberRole; } catch (Exception) { return MemberRole.responsible; }
    }
}
