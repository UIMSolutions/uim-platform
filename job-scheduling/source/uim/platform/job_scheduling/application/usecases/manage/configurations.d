/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.application.usecases.manage.configurations;

import uim.platform.job_scheduling.domain.types;
import uim.platform.job_scheduling.domain.entities.configuration;
import uim.platform.job_scheduling.domain.ports.repositories.configurations;
import uim.platform.job_scheduling.application.dto;

import uim.platform.service;
import std.conv : to;

alias Configuration = uim.platform.job_scheduling.domain.entities.configuration.Configuration;

class ManageConfigurationsUseCase : UIMUseCase {
    private ConfigurationRepository repo;

    this(ConfigurationRepository repo) {
        this.repo = repo;
    }

    Configuration get_(TenantId tenantId) {
        auto config = repo.findByTenant(tenantId);
        if (config.id.length == 0) {
            // Return default configuration
            Configuration c;
            c.tenantId = tenantId;
            c.defaultRetries = 3;
            c.defaultRetryDelayMs = 30000;
            c.maxRunDurationMs = 600000;
            c.enableAsyncMode = true;
            c.enableAlertNotifications = false;
            return c;
        }
        return config;
    }

    CommandResult update(UpdateConfigurationRequest r) {
        auto existing = repo.findByTenant(r.tenantId);

        import core.time : MonoTime;
        auto now = MonoTime.currTime.ticks;

        if (existing.id.length == 0) {
            // Create new configuration
            import std.uuid : randomUUID;
            Configuration c;
            c.id = randomUUID().to!string;
            c.tenantId = r.tenantId;
            c.defaultRetries = r.defaultRetries;
            c.defaultRetryDelayMs = r.defaultRetryDelayMs;
            c.maxRunDurationMs = r.maxRunDurationMs;
            c.enableAsyncMode = r.enableAsyncMode;
            c.enableAlertNotifications = r.enableAlertNotifications;
            c.createdAt = now;
            c.modifiedAt = now;
            repo.save(c);
            return CommandResult(true, c.id, "");
        }

        existing.defaultRetries = r.defaultRetries;
        existing.defaultRetryDelayMs = r.defaultRetryDelayMs;
        existing.maxRunDurationMs = r.maxRunDurationMs;
        existing.enableAsyncMode = r.enableAsyncMode;
        existing.enableAlertNotifications = r.enableAlertNotifications;
        existing.modifiedAt = now;

        repo.update(existing);
        return CommandResult(true, existing.id, "");
    }
}
