/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// HTTP server entry point (composition root): REST, OData v4, Fiori app, scheduler.
module app;

import uim.platform.identity_provisioning;

@safe:

version (unittest) {
} else {
  void main() {
    auto config = loadConfig();
    configureLogging(config.logLevel);
    auto container = buildContainer(config);
    if (container.seedDemoData())
      logInfo("identity-provisioning: demo data created in tenant '%s'", config.defaultTenant);
    auto registry = new ResourceRegistry(container.ports);

    auto router = new URLRouter();

    // ── REST driving adapter (/api/v1/...) ─────────────────────────────────
    new HealthController(config.serviceName).registerRoutes(router);
    new ProvisioningRestController(registry, config.defaultTenant, config.restPath).registerRoutes(router);

    // ── OData v4 driving adapter (SAP Fiori) ───────────────────────────────
    new ProvisioningODataController(registry, config.odataPath, config.defaultTenant).registerRoutes(router);

    // ── Fiori app for local development (approuter serves it on CF) ────────
    auto frontend = new FrontendController(config.frontendDir);
    frontend.registerRoutes(router);

    // ── Background worker: scheduled jobs and log retention ────────────────
    auto scheduler = new JobScheduler(container.ports.jobs, container.ports.logs, config.schedulerTenants,
      config.logRetentionDays);
    scheduler.start(config.schedulerIntervalSeconds);

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];
    auto listener = listenHTTP(settings, router);
    scope (exit)
      listener.stopListening();

    logInfo("%s listening on %s:%d (storage=%s, config from %s)", config.serviceName,
      config.host, config.port, config.storage, config.sources.join(" → "));
    logInfo("  REST   %s/{%s,statistics,run-due-jobs,resources}", config.restPath,
      registry.adapters.map!(a => a.path).join(","));
    logInfo("  OData  %s  ($metadata)", config.odataPath);
    logInfo("  Health /api/v1/health");
    if (frontend.available)
      logInfo("  Fiori  /index.html  (%s)", config.frontendDir);

    runApplication();
  }
}
