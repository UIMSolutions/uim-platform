/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.application.usecases.manage.configurations;

// import uim.platform.job_scheduling.domain.entities.configuration;
// import uim.platform.job_scheduling.domain.ports.repositories.configurations;


import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:
// alias Configuration = uim.platform.job_scheduling.domain.entities.configuration.Configuration;

class ManageConfigurationsUseCase {
  protected IConfigurationRepository repo;

  this(IConfigurationRepository repo) {
    this.repo = repo;
  }

  Configuration getConfiguration(TenantId tenantId) {
    auto config = repo.get(tenantId);
    if (!config.isNull)
      return config;

    // Return default configuration
    auto c = Configuration(tenantId);

    c.defaultRetries = 3;
    c.defaultRetryDelayMs = 30000;
    c.maxRunDurationMs = 600000;
    c.enableAsyncMode = true;
    c.enableAlertNotifications = false;
    return c;
  }

  UsecaseResult updateConfiguration(UpdateConfigurationRequest request) {
    auto existing = repo.get(request.tenantId);
    if (!repo.existsByTenant(request.tenantId)) {
      // Create new configuration
      auto c = Configuration(request.tenantId);

      c.defaultRetries = request.defaultRetries;
      c.defaultRetryDelayMs = request.defaultRetryDelayMs;
      c.maxRunDurationMs = request.maxRunDurationMs;
      c.enableAsyncMode = request.enableAsyncMode;
      c.enableAlertNotifications = request.enableAlertNotifications;

      repo.save(c);
      return UsecaseResult(true, c.id.value, "");
    }

    existing.defaultRetries = request.defaultRetries;
    existing.defaultRetryDelayMs = request.defaultRetryDelayMs;
    existing.maxRunDurationMs = request.maxRunDurationMs;
    existing.enableAsyncMode = request.enableAsyncMode;
    existing.enableAlertNotifications = request.enableAlertNotifications;
    existing.updatedAt = currentTimestamp;

    repo.update(existing);
    return UsecaseResult(true, existing.id.value, "");
  }
}

///
unittest {
    auto repo = new ConfigurationRepository();
    auto usecase = new ManageConfigurationsUseCase(repo);
    auto tenantId = TenantId("test-tenant");

    assert(usecase !is null);
}
