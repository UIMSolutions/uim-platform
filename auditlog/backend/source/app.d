/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// HTTP server entry point (composition root): REST /api/v1, OData v4, Fiori app.
module app;

import uim.platform.auditlog;

@safe:

version (unittest) {
} else {
  void main() {
    auto config = loadConfig();
    auto container = buildContainer(config);
    auto ports = container.ports;

    auto router = new URLRouter();

    // ── REST driving adapters (/api/v1) ───────────────────────────────────
    new AuditLogController(ports.writeAuditLog, ports.retrieveAuditLogs).registerRoutes(router);
    new RetentionController(ports.manageRetention).registerRoutes(router);
    new AuditConfigController(ports.manageAuditConfig).registerRoutes(router);
    new ExportController(ports.manageExports).registerRoutes(router);
    new SecurityEventController(ports.writeSecurityEvent).registerRoutes(router);
    new DataAccessController(ports.writeDataAccessLog).registerRoutes(router);
    new ConfigChangeController(ports.writeConfigChange).registerRoutes(router);
    new HealthController(config.serviceName).registerRoutes(router);

    // ── OData v4 driving adapter (SAP Fiori) ──────────────────────────────
    new AuditLogODataController(ports, config.odataPath, config.defaultTenant).registerRoutes(router);

    // ── Fiori app for local development (approuter serves it on CF) ───────
    auto frontend = new FrontendController(config.frontendDir);
    frontend.registerRoutes(router);

    // ── Background worker ────────────────────────────────────────────────
    auto worker = new RetentionWorker(ports.enforceRetention, config.retentionTenants);
    worker.start(config.retentionIntervalMinutes);

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];
    auto listener = listenHTTP(settings, router);
    scope (exit)
      listener.stopListening();

    logInfo("%s listening on %s:%d (storage=%s, config from %s)", config.serviceName,
      config.host, config.port, config.storage, config.sources.join(" → "));
    logInfo("  REST   /api/v1/{auditlog,retention,configs,exports,security-events,data-access,config-changes,health}");
    logInfo("  OData  %s  ($metadata)", config.odataPath);
    if (frontend.available)
      logInfo("  Fiori  /index.html  (%s)", config.frontendDir);

    runApplication();
  }
}
