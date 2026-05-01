/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.application.usecases.manage.visibilities;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
class ManageVisibilitiesUseCase { // TODO: UIMUseCase {
    private VisibilityRepository repo;

    this(VisibilityRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateVisibilityRequest r) {
        if (r.isNull)
            return CommandResult(false, "", "Visibility ID is required");
        if (r.name.length == 0)
            return CommandResult(false, "", "Visibility name is required");

        if (repo.existsById(r.id))
            return CommandResult(false, "", "Visibility dashboard already exists");

        Visibility v;
        v.id = r.id;
        v.tenantId = r.tenantId;
        v.name = r.name;
        v.description = r.description;
        v.status = VisibilityStatus.active;
        v.processIds = r.processIds;
        v.refreshIntervalSeconds = r.refreshIntervalSeconds;
        v.createdBy = r.createdBy;

        import core.time : MonoTime;
        auto now = MonoTime.currTime.ticks;
        v.createdAt = now;
        v.updatedAt = now;

        repo.save(v);
        return CommandResult(true, v.id, "");
    }

    Visibility getById(VisibilityId id) {
        return repo.findById(id);
    }

    Visibility[] list(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult update(UpdateVisibilityRequest r) {
        if (!repo.existsById(r.id))
            return CommandResult(false, "", "Visibility dashboard not found");

        auto existing = repo.findById(r.id);
        existing.name = r.name;
        existing.description = r.description;
        existing.refreshIntervalSeconds = r.refreshIntervalSeconds;
        existing.updatedBy = r.updatedBy;

        import core.time : MonoTime;
        existing.updatedAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, existing.id, "");
    }

    CommandResult remove(VisibilityId id) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "Visibility dashboard not found");

        repo.remove(id);
        return CommandResult(true, id.toString, "");
    }
}
