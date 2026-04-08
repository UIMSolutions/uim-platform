/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.application.usecases.manage.dashboards;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
class ManageDashboardsUseCase : UIMUseCase {
    private DashboardRepository repo;

    this(DashboardRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateDashboardRequest r) {
        auto err = SituationEvaluator.validate(r.id, r.name);
        if (err.length > 0)
            return CommandResult(false, "", err);

        auto existing = repo.findById(r.id);
        if (existing.id.length > 0)
            return CommandResult(false, "", "Dashboard already exists");

        Dashboard d;
        d.id = r.id;
        d.tenantId = r.tenantId;
        d.name = r.name;
        d.description = r.description;
        d.refreshIntervalSeconds = r.refreshIntervalSeconds;
        d.createdBy = r.createdBy;

        import core.time : MonoTime;
        auto now = MonoTime.currTime.ticks;
        d.createdAt = now;
        d.modifiedAt = now;

        repo.save(d);
        return CommandResult(true, d.id, "");
    }

    Dashboard get_(DashboardId id) {
        return repo.findById(id);
    }

    Dashboard[] list(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult update(UpdateDashboardRequest r) {
        auto existing = repo.findById(r.id);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Dashboard not found");

        existing.name = r.name;
        existing.description = r.description;
        existing.refreshIntervalSeconds = r.refreshIntervalSeconds;
        existing.modifiedBy = r.modifiedBy;

        import core.time : MonoTime;
        existing.modifiedAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, existing.id, "");
    }

    CommandResult remove(DashboardId id) {
        auto existing = repo.findById(id);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Dashboard not found");

        repo.remove(id);
        return CommandResult(true, id, "");
    }
}
