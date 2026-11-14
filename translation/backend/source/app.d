/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// HTTP server entry point (composition root): REST, OData v4, Fiori app, job worker.
module app;

import uim.platform.translation;

@safe:

version (unittest) {
} else {
  void main() {
    auto config = loadConfig();
    configureLogging(config.logLevel);
    auto container = buildContainer(config);
    auto registry = new ResourceRegistry(container.ports);

    auto router = new URLRouter();

    // ── REST driving adapter (/api/v1/translation) ─────────────────────────
    new HealthController(config.serviceName).registerRoutes(router);
    new TranslationRestController(registry, config.defaultTenant, config.restPath).registerRoutes(router);

    // ── OData v4 driving adapter (SAP Fiori) ───────────────────────────────
    new TranslationODataController(registry, config.odataPath, config.defaultTenant).registerRoutes(router);

    // ── Fiori app for local development (approuter serves it on CF) ────────
    auto frontend = new FrontendController(config.frontendDir);
    frontend.registerRoutes(router);

    // ── Background worker: asynchronous translation jobs ───────────────────
    auto worker = new JobWorker(container.ports.jobs, config.jobTenants);
    worker.start(config.jobIntervalSeconds);

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];
    auto listener = listenHTTP(settings, router);
    scope (exit)
      listener.stopListening();

    logInfo("%s listening on %s:%d (storage=%s, config from %s)", config.serviceName,
      config.host, config.port, config.storage, config.sources.join(" → "));
    logInfo("  REST   %s/{%s,translate,documents/translate,process-jobs,statistics,resources}", config.restPath,
      registry.adapters.map!(a => a.path).join(","));
    logInfo("  OData  %s  ($metadata)", config.odataPath);
    logInfo("  Health /api/v1/health");
    if (frontend.available)
      logInfo("  Fiori  /index.html  (%s)", config.frontendDir);

    runApplication();
  }
}
