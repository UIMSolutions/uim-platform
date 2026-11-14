/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// HTTP server entry point (composition root):
///   JSON API /api/v1, vibe.d REST /rest/v1, OData v4 /odata/v4/management, Fiori app.
module app;

import uim.platform.management;

@safe:

version (unittest) {
} else {
  void main() {
    auto config = loadConfig();
    configureLogging(config.logLevel);
    auto container = buildContainer(config);
    auto ports = container.ports;

    if (config.seedDemoData && ports.demoData.isEmpty(TenantId(config.defaultTenant))) {
      auto seeded = ports.demoData.seed(TenantId(config.defaultTenant));
      logInfo("management: %s", seeded.message);
    }

    auto router = new URLRouter();

    // ── vibe.d REST interfaces (/rest/v1) ─────────────────────────────────
    router.registerRestInterface(new GlobalAccountApi(ports.globalAccounts), config.restPath);
    router.registerRestInterface(new DirectoryApi(ports.directories), config.restPath);
    router.registerRestInterface(new SubaccountApi(ports.subaccounts), config.restPath);
    router.registerRestInterface(new EntitlementApi(ports.entitlements), config.restPath);
    router.registerRestInterface(new EnvironmentApi(ports.environments), config.restPath);
    router.registerRestInterface(new SubscriptionApi(ports.subscriptions), config.restPath);
    router.registerRestInterface(new ServicePlanApi(ports.servicePlans), config.restPath);
    router.registerRestInterface(new LabelApi(ports.labels), config.restPath);
    router.registerRestInterface(new EventApi(ports.events), config.restPath);
    router.registerRestInterface(new OverviewApi(ports.overview), config.restPath);

    // ── JSON API driving adapters (/api/v1) ───────────────────────────────
    new GlobalAccountController(ports.globalAccounts).registerRoutes(router);
    new DirectoryController(ports.directories).registerRoutes(router);
    new SubaccountController(ports.subaccounts).registerRoutes(router);
    new EntitlementController(ports.entitlements).registerRoutes(router);
    new EnvironmentController(ports.environments).registerRoutes(router);
    new SubscriptionController(ports.subscriptions).registerRoutes(router);
    new ServicePlanController(ports.servicePlans).registerRoutes(router);
    new LabelController(ports.labels).registerRoutes(router);
    new EventController(ports.events).registerRoutes(router);
    new OverviewController(ports.overview).registerRoutes(router);
    new HealthController(config.serviceName).registerRoutes(router);

    // ── OData v4 driving adapter (SAP Fiori) ──────────────────────────────
    new ManagementODataController(ports, config.odataPath, config.defaultTenant).registerRoutes(router);

    // ── Fiori app for local development (approuter serves it on CF) ───────
    auto frontend = new FrontendController(config.frontendDir);
    frontend.registerRoutes(router);

    // ── Background worker ────────────────────────────────────────────────
    auto worker = new EventPruningWorker(ports.pruneEvents, config.workerTenants, config.eventRetentionDays);
    worker.start(config.eventPruneIntervalMinutes);

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];
    auto listener = listenHTTP(settings, router);
    scope (exit)
      listener.stopListening();

    logInfo("%s listening on %s:%d (storage=%s, config from %s)", config.serviceName,
      config.host, config.port, config.storage, config.sources.join(" → "));
    logInfo("  JSON   %s/{accounts,directories,subaccounts,entitlements,environments,subscriptions,service-plans,labels,events,overview,health}", config.apiPath);
    logInfo("  REST   %s{global-accounts,directories,subaccounts,…}", config.restPath);
    logInfo("  OData  %s  ($metadata)", config.odataPath);
    if (frontend.available)
      logInfo("  Fiori  /index.html  (%s)", config.frontendDir);

    runApplication();
  }
}
