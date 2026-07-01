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
import uim.platform.appevents.application.dto;

@safe:

class ManageFormationsUseCase {
    private FormationRepository repo;

    this(FormationRepository repo) {
        this.repo = repo;
    }

    Formation getFormation(TenantId tenantId, FormationId id) {
        return repo.findById(tenantId, id);
    }

    Formation[] listFormations(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult createFormation(FormationDTO dto) {
        if (repo.nameExists(dto.tenantId, dto.name))
            return CommandResult(false, "", "Formation name already exists");
            
        auto f = Formation(dto.tenantId, dto.formationId.isNull ? FormationId(createId()) : dto.formationId, dto.createdBy);
        f.name = dto.name;
        f.description = dto.description;
        f.globalAccountId = dto.globalAccountId;
        f.status = dto.status;
        f.systemCount = 0;

        repo.save(f);
        return CommandResult(true, f.id.value, "");
    }

    CommandResult updateFormation(FormationDTO dto) {
        auto f = repo.findById(dto.tenantId, dto.formationId);
        if (f.isNull)
            return CommandResult(false, "", "Formation not found");

        f.name = dto.name;
        f.description = dto.description;
        f.globalAccountId = dto.globalAccountId;
        f.status = dto.status;
        if (!dto.updatedBy.isNull)
            f.updatedBy = dto.updatedBy;

        repo.update(f);
        return CommandResult(true, f.id.value, "");
    }

    CommandResult deleteFormation(TenantId tenantId, FormationId id) {
        auto f = repo.findById(tenantId, id);
        if (f.isNull)
            return CommandResult(false, "", "Formation not found");

        repo.remove(f);
        return CommandResult(true, f.id.value, "");
    }
}
