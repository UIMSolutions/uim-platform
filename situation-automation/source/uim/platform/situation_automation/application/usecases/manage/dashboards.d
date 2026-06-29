/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.application.usecases.manage.dashboards;

import uim.platform.situation_automation;

// mixin(ShowModule!());

@safe:
class ManageDashboardsUseCase { // TODO: UIMUseCase {
    private DashboardRepository repo;

    this(DashboardRepository repo) {
        this.repo = repo;
    }

    CommandResult createDashboard(CreateDashboardRequest r) {
        auto err = SituationEvaluator.validate(r.tenantId, r.dashboardId.value, r.name);
        if (err.length > 0)
            return CommandResult(false, "", err);

        auto existing = repo.findById(r.tenantId, r.dashboardId);
        if (!existing.isNull)
            return CommandResult(false, "", "Dashboard already exists");

        Dashboard d;
        d.initEntity(r.tenantId, r.dashboardId, r.createdBy);
        d.name = r.name;
        d.description = r.description;
        d.refreshIntervalSeconds = r.refreshIntervalSeconds;

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
        auto dashboard = repo.findById(r.tenantId, r.dashboardId);
        if (dashboard.isNull)
            return CommandResult(false, "", "Dashboard not found");

        dashboard.updatedAt = currentTimestamp();
        dashboard.name = r.name;
        dashboard.description = r.description;
        dashboard.refreshIntervalSeconds = r.refreshIntervalSeconds;

        repo.update(dashboard);
        return CommandResult(true, dashboard.id.value, "");
    }

    CommandResult deleteDashboard(TenantId tenantId, DashboardId id) {
        auto dashboard = repo.findById(tenantId, id);
        if (dashboard.isNull)
            return CommandResult(false, "", "Dashboard not found");

        repo.remove(dashboard);
        return CommandResult(true, dashboard.id.value, "");
    }
}
