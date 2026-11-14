/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// HTTP server entry point (composition root):
///   REST    /api/v1/service-manager/...
///   OData   /odata/v4/service-manager  ($metadata, $batch — SAP Fiori)
///   Fiori   /app/index.html            (local development; approuter on BTP)
///   Health  /health
module app;

import uim.platform.service_manager;

@safe:

version (unittest) {
} else {
  int main() {
    auto config = loadServiceManagerConfig();
    auto container = new ServiceManagerContainer(config);
    auto security = configureSecurity(config);
    container.engine.enforceScopes = security.requireAuthentication;

    auto router = new URLRouter;
    new ServiceManagerHealthController(config, security.mode).registerRoutes(router, config.restPath);
    new ServiceManagerRestController(container.engine, security, config.restPath).registerRoutes(router);

    auto odata = new ODataController(container.engine, config.odataPath, config.defaultTenant);
    odata.verifier = security.verifier;
    odata.requireAuthentication = security.requireAuthentication;
    odata.registerRoutes(router);

    auto frontend = new FrontendController(config.frontendDir);
    frontend.registerRoutes(router);

    auto worker = new CatalogSyncWorker(container.ports.catalogSync, config.catalogSyncTenants);
    worker.start(config.catalogSyncMinutes);

    auto settings = new HTTPServerSettings;
    settings.port = config.port;
    settings.bindAddresses = [config.host];
    settings.maxRequestSize = 16 * 1024 * 1024;
    auto listener = listenHTTP(settings, withRequestLogging(&router.handleRequest, config.serviceName));
    scope (exit)
      listener.stopListening();

    logServiceEvent("info", "listening", Json([
        "host": Json(config.host), "port": Json(config.port), "storage": Json(config.storage),
        "security": Json(security.mode), "rest": Json(config.restPath), "odata": Json(config.odataPath),
        "fiori": Json(frontend.available ? "/app/index.html" : ""),
        "provisioning": Json(config.syncProvisioning ? "synchronous" : "asynchronous")
      ]));
    return runApplication();
  }
}
