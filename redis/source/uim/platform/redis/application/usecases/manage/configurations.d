/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.application.usecases.manage.configurations;

import uim.platform.redis;

// mixin(ShowModule!());

@safe:

class ManageConfigurationsUseCase {
    private ConfigurationRepository repo;

    this(ConfigurationRepository repo) { this.repo = repo; }

    Configuration getConfiguration(TenantId tenantId, ConfigurationId id) {
        return repo.findById(tenantId, id);
    }

    Configuration[] listConfigurations(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Configuration getByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        return repo.findByInstance(tenantId, instanceId);
    }

    CommandResult createConfiguration(ConfigurationDTO dto) {
        ServiceInstanceId instId = dto.instanceId;
        auto existing = repo.findByInstance(dto.tenantId, instId);
        if (!existing.isNull)
            return CommandResult(false, "", "Configuration already exists for this instance");

        auto e = Configuration(dto.tenantId, dto.configurationId, dto.createdBy);
        e.instanceId = dto.instanceId;
        e.maxMemoryPolicy = dto.maxMemoryPolicy;
        e.timeout_ = dto.timeout_;
        e.maxConnections = dto.maxConnections;
        e.tlsEnabled = dto.tlsEnabled;
        e.persistenceMode = dto.persistenceMode;
        e.maxMemoryMb = dto.maxMemoryMb;
        e.notifyKeyspaceEvents = dto.notifyKeyspaceEvents;
        e.activeVersion = dto.activeVersion;

        if (!RedisValidator.isValidConfiguration(e))
            return CommandResult(false, "", "Invalid configuration: instanceId required");

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult updateConfiguration(ConfigurationDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.configurationId);
        if (existing.isNull)
            return CommandResult(false, "", "Configuration not found");

        existing.maxMemoryPolicy = dto.maxMemoryPolicy;
        existing.timeout_ = dto.timeout_;
        if (dto.maxConnections > 0) existing.maxConnections = dto.maxConnections;
        existing.tlsEnabled = dto.tlsEnabled;
        existing.persistenceMode = dto.persistenceMode;
        if (dto.maxMemoryMb > 0) existing.maxMemoryMb = dto.maxMemoryMb;
        existing.notifyKeyspaceEvents = dto.notifyKeyspaceEvents;
        if (dto.activeVersion.length > 0) existing.activeVersion = dto.activeVersion;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteConfiguration(TenantId tenantId, ConfigurationId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Configuration not found");
        repo.remove(tenantId, id);
        return CommandResult(true, id.value, "");
    }
}
