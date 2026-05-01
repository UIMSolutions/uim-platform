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

    CommandResult create(CreateEntityTypeRequest r) {
        auto err = SituationEvaluator.validate(r.id, r.name);
        if (err.length > 0)
            return CommandResult(false, "", err);

        auto existing = repo.findById(r.id);
        if (existing.id.length > 0)
            return CommandResult(false, "", "Entity type already exists");

        EntityType e;
        e.id = r.id;
        e.tenantId = r.tenantId;
        e.name = r.name;
        e.description = r.description;
        e.sourceSystem = r.sourceSystem;
        e.createdBy = r.createdBy;

        import core.time : MonoTime;
        auto now = MonoTime.currTime.ticks;
        e.createdAt = now;
        e.updatedAt = now;

        repo.save(e);
        return CommandResult(true, e.id, "");
    }

    EntityType getById(EntityTypeId id) {
        return repo.findById(id);
    }

    EntityType[] list(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult update(UpdateEntityTypeRequest r) {
        auto existing = repo.findById(r.id);
        if (existing.isNull)
            return CommandResult(false, "", "Entity type not found");

        existing.name = r.name;
        existing.description = r.description;
        existing.updatedBy = r.updatedBy;

        import core.time : MonoTime;
        existing.updatedAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, existing.id, "");
    }

    CommandResult remove(EntityTypeId id) {
        auto existing = repo.findById(id);
        if (existing.isNull)
            return CommandResult(false, "", "Entity type not found");

        repo.remove(id);
        return CommandResult(true, id.toString, "");
    }
}
