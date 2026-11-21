/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// HTTP server entry point (composition root):
///   REST    /api/v1/building-blocks, /relationships, /analysis, /export
///   OData   /odata/v4/architecture  ($metadata, $batch — SAP Fiori)
///   Fiori   /app/index.html         (local development; approuter on BTP)
///   Health  /health, /api/v1/health
module app;

import uim.platform.architecture;

@safe:

version (unittest) {
} else {
  int main() {
    auto config = loadArchitectureConfig();
    auto container = new ArchitectureContainer(config);
    auto security = configureSecurity(config);
    container.engine.enforceScopes = security.requireAuthentication;
    auto seeded = container.seedIfConfigured();

    auto router = new URLRouter;
    new ArchitectureHealthController(config, security.mode).registerRoutes(router, config.apiPath);
    new ArchitectureApiController(container.engine, security, config.apiPath).registerRoutes(router);

    auto odata = new ODataController(container.engine, config.odataPath, config.defaultTenant);
    odata.verifier = security.verifier;
    odata.requireAuthentication = security.requireAuthentication;
    odata.registerRoutes(router);

    auto frontend = new FrontendController(config.frontendDir);
    frontend.registerRoutes(router);

    auto settings = new HTTPServerSettings;
    settings.port = config.port;
    settings.bindAddresses = [config.host];
    settings.maxRequestSize = 4 * 1024 * 1024;
    auto listener = listenHTTP(settings, withRequestLogging(&router.handleRequest, config.serviceName));
    scope (exit)
      listener.stopListening();

    logServiceEvent("info", "listening", Json([
        "host": Json(config.host), "port": Json(config.port), "storage": Json(config.storage),
        "security": Json(security.mode), "api": Json(config.apiPath), "odata": Json(config.odataPath),
        "fiori": Json(frontend.available ? "/app/index.html" : ""), "seeded": Json(seeded),
        "sources": Json(config.sources.map!(s => Json(s)).array)
      ]));
    return runApplication();
  }
}
