/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.application.usecases.manage.teams;

import uim.platform.responsibility;

mixin(ShowModule!());

@safe:

class ManageTeamsUseCase {
    private TeamRepository repo;

    this(TeamRepository repo) { this.repo = repo; }

    Team getTeam(TenantId tenantId, TeamId id) {
        return repo.findById(tenantId, id);
    }

    Team[] listTeams(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Team[] listTeamsByStatus(TenantId tenantId, TeamStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    CommandResult createTeam(TeamDTO dto) {
        auto t = Team(dto.tenantId); //, dto.createdBy);
        t.id          = dto.teamId;
        t.name        = dto.name;
        t.description = dto.description;
        t.teamTypeId  = dto.teamTypeId;
        t.categoryId  = dto.categoryId;
        t.status      = parseStatus(dto.status);
        t.scope_      = parseScope(dto.scope_);
        if (t.name.isEmpty)
            return CommandResult(false, "", "Team name is required");
        repo.save(t);
        return CommandResult(true, t.id.value, "");
    }

    CommandResult updateTeam(TeamDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.teamId);
        if (existing.isNull)
            return CommandResult(false, "", "Team not found");
        if (dto.name.length > 0)        existing.name        = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.teamTypeId.length > 0)  existing.teamTypeId  = dto.teamTypeId;
        if (!dto.updatedBy.isNull)      existing.updatedBy   = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteTeam(TenantId tenantId, TeamId id) {
        auto e = repo.findById(tenantId, id);
        if (e.isNull)
            return CommandResult(false, "", "Team not found");
        repo.remove(e);
        return CommandResult(true, e.id.value, "");
    }

    private static TeamStatus parseStatus(string s) {
        
        try { return s.to!TeamStatus; } catch (Exception) { return TeamStatus.active; }
    }

    private static AssignmentScope parseScope(string s) {
        
        try { return s.to!AssignmentScope; } catch (Exception) { return AssignmentScope.global_; }
    }
}
