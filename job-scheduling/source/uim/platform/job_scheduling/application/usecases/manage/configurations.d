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
        if (!repo.existsByTenant(tenantId)) {
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
        return repo.findByTenant(tenantId);
    }

    CommandResult update(UpdateConfigurationRequest request) {
        import core.time : MonoTime;
        auto now = MonoTime.currTime.ticks;

        if (!repo.existsByTenant(request.tenantId)) {
            // Create new configuration
            import std.uuid : randomUUID;
            Configuration c;
            c.id = randomUUID();
            c.tenantId = request.tenantId;
            c.defaultRetries = request.defaultRetries;
            c.defaultRetryDelayMs = request.defaultRetryDelayMs;
            c.maxRunDurationMs = request.maxRunDurationMs;
            c.enableAsyncMode = request.enableAsyncMode;
            c.enableAlertNotifications = request.enableAlertNotifications;
            c.createdAt = now;
            c.modifiedAt = now;
            repo.save(c);
            return CommandResult(true, c.id, "");
        }

        auto existing = repo.findByTenant(request.tenantId);
        existing.defaultRetries = request.defaultRetries;
        existing.defaultRetryDelayMs = request.defaultRetryDelayMs;
        existing.maxRunDurationMs = request.maxRunDurationMs;
        existing.enableAsyncMode = request.enableAsyncMode;
        existing.enableAlertNotifications = request.enableAlertNotifications;
        existing.modifiedAt = now;

        repo.update(existing);
        return CommandResult(true, existing.id.toString, "");
    }
}
