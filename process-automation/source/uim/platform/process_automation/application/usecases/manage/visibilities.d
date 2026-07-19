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
            
        if (r.name.isEmpty)
            return CommandResult(false, "", "Visibility name is required");

        if (repo.existsById(r.tenantId, r.visibilityId))
            return CommandResult(false, "", "Visibility dashboard already exists");

        auto v = Visibility(r.tenantId, r.visibilityId, r.createdBy);
        v.name = r.name;
        v.description = r.description;
        v.status = VisibilityStatus.active;
        v.processIds = r.processIds.map!(pid => ProcessId(pid)).array;
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
        auto existing = repo.findById(r.tenantId, r.visibilityId);
        if (existing.isNull)
            return CommandResult(false, "", "Visibility dashboard not found");

        existing.name = r.name;
        existing.description = r.description;
        existing.refreshIntervalSeconds = r.refreshIntervalSeconds;
        existing.updatedBy = r.updatedBy;

        
        existing.updatedAt = currentTimestamp;

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
