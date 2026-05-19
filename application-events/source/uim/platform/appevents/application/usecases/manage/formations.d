/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.application.usecases.manage.formations;

import uim.platform.service;
import uim.platform.appevents.domain.entities.formation;
import uim.platform.appevents.domain.repositories.formations;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.formation_status;
import uim.platform.appevents.application.dto;
import std.uuid : randomUUID;
import std.conv : to;

@safe:

class ManageFormationsUseCase {
    private FormationRepository _repo;

    this(FormationRepository repo) {
        _repo = repo;
    }

    Formation getFormation(TenantId tenantId, FormationId id) {
        return _repo.findById(tenantId, id);
    }

    Formation[] listFormations(TenantId tenantId) {
        return _repo.findAll(tenantId);
    }

    CommandResult createFormation(TenantId tenantId, FormationDTO dto) {
        if (_repo.nameExists(tenantId, dto.name))
            return CommandResult(false, "Formation name already exists");
        Formation f;
        f.id = FormationId(randomUUID().to!string);
        f.tenantId = tenantId;
        f.name = dto.name;
        f.description = dto.description;
        f.globalAccountId = dto.globalAccountId;
        f.status = dto.status;
        f.systemCount = 0;
        _repo.save(tenantId, f);
        return CommandResult(true, f.id.value);
    }

    CommandResult updateFormation(TenantId tenantId, FormationId id, FormationDTO dto) {
        auto f = _repo.findById(tenantId, id);
        if (f.id.isNull) return CommandResult(false, "Formation not found");
        f.name = dto.name;
        f.description = dto.description;
        f.globalAccountId = dto.globalAccountId;
        f.status = dto.status;
        _repo.save(tenantId, f);
        return CommandResult(true, id.value);
    }

    CommandResult deleteFormation(TenantId tenantId, FormationId id) {
        auto f = _repo.findById(tenantId, id);
        if (f.id.isNull) return CommandResult(false, "Formation not found");
        _repo.remove(tenantId, id);
        return CommandResult(true, id.value);
    }
}
