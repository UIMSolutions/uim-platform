/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.application.usecases.manage.team_types;

import uim.platform.responsibility;

// mixin(ShowModule!());

@safe:

class ManageTeamTypesUseCase {
    private TeamTypeRepository repo;

    this(TeamTypeRepository repo) { this.repo = repo; }

    TeamType getType(TenantId tenantId, TeamTypeId id) {
        return repo.findById(tenantId, id);
    }

    TeamType[] listTypes(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    TeamType[] listTypesByCategory(TenantId tenantId, string categoryId) {
        return repo.findByCategory(tenantId, categoryId);
    }

    CommandResult createType(TeamTypeDTO dto) {
        auto t = TeamType(dto.tenantId, dto.typeId, dto.createdBy);
        t.name        = dto.name;
        t.description = dto.description;
        t.code        = dto.code;
        t.categoryId  = dto.categoryId;
        if (t.name.length == 0)
            return CommandResult(false, "", "Team type name is required");
        repo.save(t);
        return CommandResult(true, t.id.value, "");
    }

    CommandResult updateType(TeamTypeDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.typeId);
        if (existing.isNull)
            return CommandResult(false, "", "Team type not found");
        if (dto.name.length > 0)        existing.name        = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.code.length > 0)        existing.code        = dto.code;
        if (dto.categoryId.length > 0)  existing.categoryId  = dto.categoryId;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteType(TenantId tenantId, TeamTypeId id) {
        auto e = repo.findById(tenantId, id);
        if (e.isNull)
            return CommandResult(false, "", "Team type not found");
        repo.remove(e);
        return CommandResult(true, e.id.value, "");
    }
}
