/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.application.usecases.manage.configurations;

// import uim.platform.job_scheduling.domain.types;
// import uim.platform.job_scheduling.domain.entities.configuration;
// import uim.platform.job_scheduling.domain.ports.repositories.configurations;
// import uim.platform.job_scheduling.application.dto;

// import uim.platform.service;

import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:
// alias Configuration = uim.platform.job_scheduling.domain.entities.configuration.Configuration;

class ManageConfigurationsUseCase { // TODO: UIMUseCase {
  private ConfigurationRepository repo;

  this(ConfigurationRepository repo) {
    this.repo = repo;
  }

  Configuration getConfiguration(TenantId tenantId) {
    auto config = repo.get(tenantId);
    if (!config.isNull)
      config;

    // Return default configuration
    Configuration c;
    c.initEntity(tenantId);

    c.defaultRetries = 3;
    c.defaultRetryDelayMs = 30000;
    c.maxRunDurationMs = 600000;
    c.enableAsyncMode = true;
    c.enableAlertNotifications = false;
    return c;
  }

  CommandResult updateConfiguration(UpdateConfigurationRequest request) {
    import core.time : MonoTime;
    auto now = MonoTime.currTime.ticks;

    auto existing = repo.get(request.tenantId);
    if (!repo.existsByTenant(request.tenantId)) {
      // Create new configuration
      Configuration c;
      c.initEntity(request.tenantId);
      c.defaultRetries = request.defaultRetries;
      c.defaultRetryDelayMs = request.defaultRetryDelayMs;
      c.maxRunDurationMs = request.maxRunDurationMs;
      c.enableAsyncMode = request.enableAsyncMode;
      c.enableAlertNotifications = request.enableAlertNotifications;

      repo.save(c);
      return CommandResult(true, c.id.value, "");
    }

    existing.defaultRetries = request.defaultRetries;
    existing.defaultRetryDelayMs = request.defaultRetryDelayMs;
    existing.maxRunDurationMs = request.maxRunDurationMs;
    existing.enableAsyncMode = request.enableAsyncMode;
    existing.enableAlertNotifications = request.enableAlertNotifications;
    existing.updatedAt = now;

    repo.update(existing);
    return CommandResult(true, existing.id.value, "");
  }
}
