/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.application.usecases.manage.visibilities;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
class ManageVisibilitiesUseCase {
    private IVisibilityRepository repo;

    this(IVisibilityRepository repo) {
        this.repo = repo;
    }

    UsecaseResult createVisibility(CreateVisibilityRequest r) {
        if (r.visibilityId.isEmpty)
            return UsecaseResult(false, "", "Visibility ID is required");
            
        if (r.name.isEmpty)
            return UsecaseResult(false, "", "Visibility name is required");

        if (repo.existsById(r.tenantId, r.visibilityId))
            return UsecaseResult(false, "", "Visibility dashboard already exists");

        auto v = Visibility(r.tenantId, r.visibilityId, r.createdBy);
        v.name = r.name;
        v.description = r.description;
        v.status = VisibilityStatus.active;
        v.processIds = r.processIds.map!(pid => ProcessId(pid)).array;
        v.refreshIntervalSeconds = r.refreshIntervalSeconds;

        repo.save(v);
        return UsecaseResult(true, v.id.value, "");
    }

    Visibility getVisibility(TenantId tenantId, VisibilityId visibilityId) {
        return repo.findById(tenantId, visibilityId);
    }

    Visibility[] listVisibilities(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    UsecaseResult updateVisibility(UpdateVisibilityRequest r) {
        auto existing = repo.findById(r.tenantId, r.visibilityId);
        if (existing.isNull)
            return UsecaseResult(false, "", "Visibility dashboard not found");

        existing.name = r.name;
        existing.description = r.description;
        existing.refreshIntervalSeconds = r.refreshIntervalSeconds;
        existing.updatedBy = r.updatedBy;

        
        existing.updatedAt = currentTimestamp;

        repo.update(existing);
        return UsecaseResult(true, existing.id.value, "");
    }

    UsecaseResult deleteVisibility(TenantId tenantId, VisibilityId visibilityId) {
        auto visibility = repo.findById(tenantId, visibilityId);
        if (visibility.isNull)
            return UsecaseResult(false, "", "Visibility dashboard not found");

        repo.remove(visibility);
        return UsecaseResult(true, visibility.id.value, "");
    }
}
