/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// HTTP server entry point (composition root):
///   REST    /api/v1/...                 (validate, profiles, duplicates, addresses, datasets)
///   OData   /odata/v4/data-quality      ($metadata, $batch — SAP Fiori)
///   Fiori   /app/index.html             (local development; approuter on BTP)
///   Health  /health, /api/v1/health
module app;

import uim.platform.data_quality;

@safe:

version (unittest) {
} else {
  int main() {
    auto config = loadDqConfig();
    auto container = new DqContainer(config);
    auto security = configureSecurity(config);
    container.engine.enforceScopes = security.requireAuthentication;

    auto router = new URLRouter;
    new DqHealthController(config, security.mode).registerRoutes(router, config.apiPath);
    new DqApiController(container.ports, security, config.apiPath, config.serviceVersion, config.maxRequestBytes)
      .registerRoutes(router);

    auto odata = new ODataController(container.engine, config.odataPath, config.defaultTenant);
    odata.verifier = security.verifier;
    odata.requireAuthentication = security.requireAuthentication;
    odata.registerRoutes(router);

    auto frontend = new FrontendController(config.frontendDir);
    frontend.registerRoutes(router);

    auto worker = new CleansingJobWorker(container.ports.cleansingJobs, config.jobTenants);
    worker.start(config.jobIntervalSeconds);

    auto settings = new HTTPServerSettings;
    settings.port = config.port;
    settings.bindAddresses = [config.host];
    settings.maxRequestSize = config.maxRequestBytes;
    auto listener = listenHTTP(settings, withRequestLogging(&router.handleRequest, config.serviceName));
    scope (exit)
      listener.stopListening();

    logServiceEvent("info", "listening", Json([
        "host": Json(config.host), "port": Json(config.port), "storage": Json(config.storage),
        "security": Json(security.mode), "api": Json(config.apiPath), "odata": Json(config.odataPath),
        "fiori": Json(frontend.available ? "/app/index.html" : ""),
        "jobIntervalSeconds": Json(config.jobIntervalSeconds), "sources": Json(config.sources.map!(s => Json(s)).array)
      ]));
    return runApplication();
  }
}
