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

    CommandResult createVisibility(CreateVisibilityRequest r) {
        if (r.visibilityId.isEmpty)
            return CommandResult(false, "", "Visibility ID is required");
        if (r.name.length == 0)
            return CommandResult(false, "", "Visibility name is required");

        if (repo.existsById(r.tenantId, r.visibilityId))
            return CommandResult(false, "", "Visibility dashboard already exists");

        Visibility v;
        v.initEntity(r.tenantId, r.createdBy);
        v.id = r.visibilityId;
        v.name = r.name;
        v.description = r.description;
        v.status = VisibilityStatus.active;
        v.processIds = r.processIds.map!(pid => ProcessId(pid)).array.toJson;
        v.refreshIntervalSeconds = r.refreshIntervalSeconds;

        repo.save(v);
        return CommandResult(true, v.id.value, "");
    }

    Visibility getVisibility(TenantId tenantId, VisibilityId visibilityId) {
        return repo.findById(tenantId, visibilityId);
    }

    Visibility[] listVisibilities(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult updateVisibility(UpdateVisibilityRequest r) {
        if (!repo.existsById(r.tenantId, r.visibilityId))
            return CommandResult(false, "", "Visibility dashboard not found");

        auto existing = repo.findById(r.tenantId, r.visibilityId);
        existing.name = r.name;
        existing.description = r.description;
        existing.refreshIntervalSeconds = r.refreshIntervalSeconds;
        existing.updatedBy = r.updatedBy;

        import core.time : MonoTime;
        existing.updatedAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteVisibility(TenantId tenantId, VisibilityId visibilityId) {
        auto visibility = repo.findById(tenantId, visibilityId);
        if (visibility.isNull)
            return CommandResult(false, "", "Visibility dashboard not found");

        repo.remove(visibility);
        return CommandResult(true, visibility.id.value, "");
    }
}
