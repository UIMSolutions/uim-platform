/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// HTTP server entry point (composition root): REST /api/v1/transport, OData v4, Fiori app.
module app;

import uim.platform.transport;

@safe:

version (unittest) {
} else {
  void main() {
    auto config = loadConfig();
    configureLogging(config.logLevel);
    auto container = buildContainer(config);
    auto ports = container.ports;

    auto router = new URLRouter();

    // ── REST driving adapters (/api/v1/transport) ─────────────────────────
    new TransportNodeController(ports.nodes, ports.operations).registerRoutes(router);
    new TransportRouteController(ports.routes).registerRoutes(router);
    new TransportRequestController(ports.requests, ports.operations).registerRoutes(router);
    new ImportQueueEntryController(ports.queue).registerRoutes(router);
    new TransportActionController(ports.actions).registerRoutes(router);
    new TransportOperationsController(ports, config.defaultTenant).registerRoutes(router);
    new HealthController(config.serviceName, config.serviceVersion).registerRoutes(router);

    // ── OData v4 driving adapter (SAP Fiori) ──────────────────────────────
    new TransportODataController(ports, config.odataPath, config.defaultTenant).registerRoutes(router);

    // ── Fiori app for local development (approuter serves it on CF) ───────
    auto frontend = new FrontendController(config.frontendDir);
    frontend.registerRoutes(router);

    // ── Background worker ────────────────────────────────────────────────
    auto worker = new AutoImportWorker(ports, config.autoImportTenants);
    worker.start(config.autoImportIntervalMinutes);

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];
    auto listener = listenHTTP(settings, router);
    scope (exit)
      listener.stopListening();

    logInfo("%s %s listening on %s:%d (storage=%s, config from %s)", config.serviceName, config.serviceVersion,
      config.host, config.port, config.storage, config.sources.join(" → "));
    logInfo("  REST   /api/v1/transport/{nodes,routes,requests,queue-entries,actions,nodes-import,statistics,landscape}");
    logInfo("  Health /api/v1/health");
    logInfo("  OData  %s  ($metadata)", config.odataPath);
    if (frontend.available)
      logInfo("  Fiori  /index.html  (%s)", config.frontendDir);

    runApplication();
  }
}
