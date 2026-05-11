/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.application.usecases.manage.dashboards;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
class ManageDashboardsUseCase { // TODO: UIMUseCase {
    private DashboardRepository repo;

    this(DashboardRepository repo) {
        this.repo = repo;
    }

    CommandResult createDashboard(CreateDashboardRequest r) {
        auto err = SituationEvaluator.validate(r.id, r.name);
        if (err.length > 0)
            return CommandResult(false, "", err);

        auto existing = repo.findById(r.id);
        if (!existing.isNull)
            return CommandResult(false, "", "Dashboard already exists");

        Dashboard d;
        d.initEntity(r.tenantId, r.createdBy);
        d.id = r.dashboardId;
        d.name = r.name;
        d.description = r.description;
        d.refreshIntervalSeconds = r.refreshIntervalSeconds;

        import core.time : MonoTime;
        auto now = MonoTime.currTime.ticks;
        d.createdAt = now;
        d.updatedAt = now;

        repo.save(d);
        return CommandResult(true, d.id.value, "");
    }

    Dashboard getDashboard(TenantId tenantId, DashboardId id) {
        return repo.findById(tenantId, id);
    }

    Dashboard[] listDashboards(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult updateDashboard(UpdateDashboardRequest r) {
        auto existing = repo.findById(r.tenantId, r.id);
        if (existing.isNull)
            return CommandResult(false, "", "Dashboard not found");

        existing.name = r.name;
        existing.description = r.description;
        existing.refreshIntervalSeconds = r.refreshIntervalSeconds;
        existing.updatedBy = r.updatedBy;

        import core.time : MonoTime;
        existing.updatedAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteDashboard(TenantId tenantId, DashboardId id) {
        auto dashboard = repo.findById(tenantId, id);
        if (dashboard.isNull)
            return CommandResult(false, "", "Dashboard not found");

        repo.remove(dashboard);
        return CommandResult(true, id.value, "");
    }
}
