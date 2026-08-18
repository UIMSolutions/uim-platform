/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_retention.application.usecases.manage.legal_entities;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ManageLegalEntitiesUseCase {
    private ILegalEntityRepository repo;

    this(ILegalEntityRepository repo) {
        this.repo = repo;
    }

    UsecaseResult createLegalEntity(CreateLegalEntityRequest req) {
        import std.uuid : randomUUID;

        if (req.name.isEmpty)
            return UsecaseResult(false, "", "Legal entity name is required");

        LegalEntity le;
        le.id = LegalEntityId(generateId);
        le.tenantId = req.tenantId;
        le.name = req.name;
        le.description = req.description;
        le.country = req.country;
        le.region = req.region;
        le.isActive = true;
        le.createdBy = req.createdBy;
        le.createdAt = clockSeconds();

        repo.save(le);
        return UsecaseResult(true, le.id.value, "");
    }

    UsecaseResult updateLegalEntity(UpdateLegalEntityRequest req) {
        auto entity = repo.findById(req.tenantId, req.entityId);
        if (entity.isNull)
            return UsecaseResult(false, "", "Legal entity not found");

        if (req.name.length > 0)
            entity.name = req.name;
        if (req.description.length > 0)
            entity.description = req.description;
        if (req.country.length > 0)
            entity.country = req.country;
        if (req.region.length > 0)
            entity.region = req.region;
        entity.isActive = req.isActive;
        entity.updatedAt = clockSeconds();

        repo.update(entity);
        return UsecaseResult(true, entity.id.value, "");
    }

    bool hasLegalEntity(TenantId tenantId, LegalEntityId id) {
        return repo.existsById(tenantId, id);
    }

    LegalEntity getLegalEntity(TenantId tenantId, LegalEntityId id) {
        return repo.findById(tenantId, id);
    }

    LegalEntity[] listLegalEntities(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    UsecaseResult deleteLegalEntity(TenantId tenantId, LegalEntityId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return UsecaseResult(false, "", "Legal entity not found");

        repo.remove(entity);
        return UsecaseResult(true, entity.id.value, "");
    }
}
