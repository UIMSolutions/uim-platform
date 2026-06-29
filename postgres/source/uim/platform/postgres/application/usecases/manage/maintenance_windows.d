/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.application.usecases.manage.maintenance_windows;

import uim.platform.postgres;

// mixin(ShowModule!());

@safe:

class ManageMaintenanceWindowsUseCase {
    private MaintenanceWindowRepository repo;

    this(MaintenanceWindowRepository repo) { this.repo = repo; }

    MaintenanceWindow getMaintenanceWindow(TenantId tenantId, MaintenanceWindowId id) {
        return repo.findById(tenantId, id);
    }

    MaintenanceWindow getByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        return repo.findByInstance(tenantId, instanceId);
    }

    MaintenanceWindow[] listMaintenanceWindows(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult createMaintenanceWindow(MaintenanceWindowDTO dto) {
        MaintenanceWindow e;
        e.initEntity(dto.tenantId, dto.createdBy);
        e.id = dto.maintenanceWindowId;
        e.instanceId = dto.instanceId;
        e.dayOfWeek = dto.dayOfWeek;
        e.startHourUtc = dto.startHourUtc;
        e.durationHours = dto.durationHours;
        e.autoMinorVersionUpgrade = dto.autoMinorVersionUpgrade;
        e.status = MaintenanceStatus.scheduled;

        if (e.instanceId.value.length == 0)
            return CommandResult(false, "", "instanceId is required");

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult updateMaintenanceWindow(MaintenanceWindowDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.maintenanceWindowId);
        if (existing.isNull)
            return CommandResult(false, "", "Maintenance window not found");
        if (dto.dayOfWeek.length > 0) existing.dayOfWeek = dto.dayOfWeek;
        if (dto.startHourUtc >= 0) existing.startHourUtc = dto.startHourUtc;
        if (dto.durationHours > 0) existing.durationHours = dto.durationHours;
        existing.autoMinorVersionUpgrade = dto.autoMinorVersionUpgrade;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteMaintenanceWindow(TenantId tenantId, MaintenanceWindowId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Maintenance window not found");
        repo.removeById(tenantId, id);
        return CommandResult(true, id.value, "");
    }
}
