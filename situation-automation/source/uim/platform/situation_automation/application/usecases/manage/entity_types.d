/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.application.usecases.manage.entity_types;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
class ManageEntityTypesUseCase { // TODO: UIMUseCase {
    private EntityTypeRepository repo;

    this(EntityTypeRepository repo) {
        this.repo = repo;
    }

    CommandResult createEntityType(CreateEntityTypeRequest r) {
        auto err = SituationEvaluator.validate(r.tenantId, r.entityTypeId.value, r.name);
        if (err.length > 0)
            return CommandResult(false, "", err);

        auto existing = repo.findById(r.tenantId, r.entityTypeId);
        if (!existing.isNull)
            return CommandResult(false, "", "Entity type already exists");

        EntityType e;
        e.initEntity(r.tenantId, r.entityTypeId, r.createdBy);
        
        e.name = r.name;
        e.description = r.description;
        e.sourceSystem = r.sourceSystem;

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    EntityType getEntityTypeById(TenantId tenantId, EntityTypeId id) {
        return repo.findById(tenantId, id);
    }

    EntityType[] listEntityTypes(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult updateEntityType(UpdateEntityTypeRequest r) {
        auto existing = repo.findById(r.tenantId, r.entityTypeId);
        if (existing.isNull)
            return CommandResult(false, "", "Entity type not found");

        existing.name = r.name;
        existing.description = r.description;
        existing.updatedBy = r.updatedBy;

        import core.time : MonoTime;
        existing.updatedAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteEntityType(TenantId tenantId, EntityTypeId id) {
        auto type = repo.findById(tenantId, id);
        if (type.isNull)
            return CommandResult(false, "", "Entity type not found");

        repo.remove(type);
        return CommandResult(true, type.id.value, "");
    }
}
