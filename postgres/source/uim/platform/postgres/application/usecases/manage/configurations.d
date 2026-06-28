/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.application.usecases.manage.configurations;

import uim.platform.postgres;

// mixin(ShowModule!());

@safe:

class ManageConfigurationsUseCase {
    private ConfigurationRepository repo;

    this(ConfigurationRepository repo) { this.repo = repo; }

    Configuration getConfiguration(TenantId tenantId, ConfigurationId id) {
        return repo.findById(tenantId, id);
    }

    Configuration getByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        return repo.findByInstance(tenantId, instanceId);
    }

    Configuration[] listConfigurations(TenantId tenantId) {
        return repo.find(tenantId);
    }

    CommandResult createConfiguration(ConfigurationDTO dto) {
        Configuration e;
        e.initEntity(dto.tenantId, dto.createdBy);
        e.id = dto.configurationId;
        e.instanceId = dto.instanceId;
        e.auditLogLevels = dto.auditLogLevels;
        e.backupRetentionPeriod = dto.backupRetentionPeriod;
        e.locale = dto.locale;
        e.maxConnections = dto.maxConnections;
        e.workMem = dto.workMem;
        e.sharedBuffersMb = dto.sharedBuffersMb;
        e.maintenanceWindowDay = dto.maintenanceWindowDay;
        e.maintenanceWindowStartHour = dto.maintenanceWindowStartHour;
        e.maintenanceWindowDuration = dto.maintenanceWindowDuration;

        if (e.instanceId.value.length == 0)
            return CommandResult(false, "", "instanceId is required");

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult updateConfiguration(ConfigurationDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.configurationId);
        if (existing.isNull)
            return CommandResult(false, "", "Configuration not found");
        if (dto.auditLogLevels.length > 0) existing.auditLogLevels = dto.auditLogLevels;
        if (dto.backupRetentionPeriod > 0) existing.backupRetentionPeriod = dto.backupRetentionPeriod;
        if (dto.locale.length > 0) existing.locale = dto.locale;
        if (dto.maxConnections > 0) existing.maxConnections = dto.maxConnections;
        if (dto.workMem > 0) existing.workMem = dto.workMem;
        if (dto.sharedBuffersMb > 0) existing.sharedBuffersMb = dto.sharedBuffersMb;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteConfiguration(TenantId tenantId, ConfigurationId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Configuration not found");
        repo.removeById(tenantId, id);
        return CommandResult(true, id.value, "");
    }
}
