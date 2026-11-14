/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// HTTP server entry point (composition root): REST /api/v1, vibe.d REST
/// interface /rest/v1, OData v4 and the Fiori app.
module app;

import uim.platform.agentry;

@safe:

version (unittest) {
} else {
  void main() {
    auto config = loadConfig();
    configureLogging(config.logLevel);
    auto container = buildContainer(config);
    auto ports = container.ports;

    auto router = new URLRouter();

    // ── REST driving adapters (/api/v1/agentry) ───────────────────────────
    new MobileApplicationController(ports.mobileApplications, config.apiPath).registerRoutes(router);
    new AppDefinitionController(ports.appDefinitions, config.apiPath).registerRoutes(router);
    new AppVersionController(ports.appVersions, config.apiPath).registerRoutes(router);
    new DeviceController(ports.devices, config.apiPath).registerRoutes(router);
    new SyncSessionController(ports.syncSessions, config.apiPath).registerRoutes(router);
    new BackendConnectionController(ports.backendConnections, config.apiPath).registerRoutes(router);
    new DeploymentController(ports.deployments, config.apiPath).registerRoutes(router);
    new HealthController(config.serviceName).registerRoutes(router);

    // ── vibe.d REST interface (/rest/v1/agentry/app-definitions) ──────────
    router.registerRestInterface(new AppDefinitionService(ports.appDefinitions),
      config.restPath.stripRight("/") ~ "/app-definitions");

    // ── OData v4 driving adapter (SAP Fiori) ──────────────────────────────
    new AgentryODataController(ports, config.odataPath, config.defaultTenant).registerRoutes(router);

    // ── Fiori app for local development (approuter serves it on CF) ───────
    auto frontend = new FrontendController(config.frontendDir);
    frontend.registerRoutes(router);

    // ── Background worker ─────────────────────────────────────────────────
    auto watchdog = new SyncWatchdogWorker(ports.syncSessions, config.watchdogTenants, config.syncTimeoutMinutes);
    watchdog.start(config.watchdogIntervalMinutes);

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];
    auto listener = listenHTTP(settings, router);
    scope (exit)
      listener.stopListening();

    logInfo("%s listening on %s:%d (storage=%s, config from %s)", config.serviceName,
      config.host, config.port, config.storage, config.sources.join(" → "));
    logInfo("  REST   %s/{mobile-applications,app-definitions,app-versions,devices,sync-sessions,backend-connections,deployments}",
      config.apiPath);
    logInfo("  REST   %s/app-definitions  (vibe.d REST interface)", config.restPath);
    logInfo("  OData  %s  ($metadata)", config.odataPath);
    logInfo("  Health /api/v1/health");
    if (frontend.available)
      logInfo("  Fiori  /index.html  (%s)", config.frontendDir);

    runApplication();
  }
}
