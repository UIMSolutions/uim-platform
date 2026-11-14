/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// HTTP server entry point (composition root):
///   REST    /api/v1/task-center/...
///   OData   /odata/v4/task-center  ($metadata, $batch — SAP Fiori)
///   Fiori   /app/index.html        (local development; approuter on BTP)
///   Health  /health
module app;

import uim.platform.task_center;

@safe:

version (unittest) {
} else {
  int main() {
    auto config = loadTaskCenterConfig();
    auto container = new TaskCenterContainer(config);
    auto security = configureSecurity(config);
    container.engine.enforceScopes = security.requireAuthentication;

    auto router = new URLRouter;
    new TaskCenterHealthController(config, security.mode).registerRoutes(router, config.restPath);
    new TaskCenterRestController(container.engine, security, config.restPath).registerRoutes(router);

    auto odata = new ODataController(container.engine, config.odataPath, config.defaultTenant);
    odata.verifier = security.verifier;
    odata.requireAuthentication = security.requireAuthentication;
    odata.registerRoutes(router);

    auto frontend = new FrontendController(config.frontendDir);
    frontend.registerRoutes(router);

    auto worker = new ProviderSyncWorker(container.ports.sync, config.syncTenants);
    worker.start(config.syncIntervalSeconds);

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
        "providerSync": Json(config.syncIntervalSeconds)
      ]));
    return runApplication();
  }
}
