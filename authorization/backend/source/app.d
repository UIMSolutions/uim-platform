/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// HTTP server entry point (composition root):
///   JSON API  /api/v1/...                       (applications, policies, assignments, evaluate, ...)
///   REST      /rest/v1/authorization/...        (vibe.d REST interface: check, principals, statistics)
///   OData     /odata/v4/authorization           ($metadata, $batch — SAP Fiori)
///   Web       /web                              (Diet + daisyUI dashboard)
///   Fiori     /app/index.html                   (local development; approuter on BTP)
///   Health    /health
module app;

import vibe.web.rest : registerRestInterface;
import uim.platform.authorization;

@safe:

version (unittest) {
} else {
  int main() {
    auto config = loadAuthorizationConfig();
    configureLogging(config.logLevel);
    auto container = new AuthorizationContainer(config);
    container.bootstrap();
    auto security = configureSecurity(config);
    container.engine.enforceScopes = security.requireAuthentication;

    auto router = new URLRouter;
    new AuthorizationHealthController(config, security.mode).registerRoutes(router, config.apiPath);
    new AuthorizationApiController(container.engine, container.ports, security, config.apiPath).registerRoutes(router);
    (() @trusted => router.registerRestInterface(new AuthorizationRuntimeApi(container.engine, container.ports, security),
      config.restPath))();

    auto odata = new ODataController(container.engine, config.odataPath, config.defaultTenant);
    odata.verifier = security.verifier;
    odata.requireAuthentication = security.requireAuthentication;
    odata.registerRoutes(router);

    new DashboardController(container.engine, security, config).registerRoutes(router);
    auto frontend = new FrontendController(config.frontendDir);
    frontend.registerRoutes(router);

    auto worker = new DecisionRetentionWorker(container.ports.decisions, config.workerTenants,
      config.decisionRetentionDays);
    worker.start(config.decisionPruneMinutes);

    auto settings = new HTTPServerSettings;
    settings.port = config.port;
    settings.bindAddresses = [config.host];
    settings.maxRequestSize = 16 * 1024 * 1024;
    auto listener = listenHTTP(settings, withRequestLogging(&router.handleRequest, config.serviceName));
    scope (exit)
      listener.stopListening();

    logAuthorizationEvent("info", "listening", Json([
        "host": Json(config.host), "port": Json(config.port), "storage": Json(config.storage),
        "security": Json(security.mode), "api": Json(config.apiPath), "rest": Json(config.restPath),
        "odata": Json(config.odataPath), "web": Json(config.webPath),
        "fiori": Json(frontend.available ? "/app/index.html" : "")
      ]));
    return runApplication();
  }
}
