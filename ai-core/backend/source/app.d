/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// HTTP server entry point (composition root):
///   AI API  /api/v2/lm/..., /api/v2/admin/...   (SAP AI Core compatible)
///   OData   /odata/v4/ai-core  ($metadata, $batch — SAP Fiori)
///   Fiori   /app/index.html    (local development; approuter on BTP)
///   Health  /health, /api/v1/health
module app;

import uim.platform.ai_core;

@safe:

version (unittest) {
} else {
  int main() {
    auto config = loadAiCoreConfig();
    auto container = new AiCoreContainer(config);
    auto security = configureSecurity(config);
    container.engine.enforceScopes = security.requireAuthentication;

    auto router = new URLRouter;
    new AiCoreHealthController(config, security.mode).registerRoutes(router, config.aiApiPath);
    new AiApiController(container.ports, security, config.aiApiPath, config.defaultResourceGroup, config.serviceVersion)
      .registerRoutes(router);

    auto odata = new ODataController(container.engine, config.odataPath, config.defaultTenant);
    odata.verifier = security.verifier;
    odata.requireAuthentication = security.requireAuthentication;
    odata.registerRoutes(router);

    auto frontend = new FrontendController(config.frontendDir);
    frontend.registerRoutes(router);

    auto reconciler = new ReconcilerWorker(container.ports.reconciler, config.reconcileTenants);
    reconciler.start(config.reconcileIntervalSeconds);

    auto settings = new HTTPServerSettings;
    settings.port = config.port;
    settings.bindAddresses = [config.host];
    settings.maxRequestSize = 4 * 1024 * 1024;
    auto listener = listenHTTP(settings, withRequestLogging(&router.handleRequest, config.serviceName));
    scope (exit)
      listener.stopListening();

    logServiceEvent("info", "listening", Json([
        "host": Json(config.host), "port": Json(config.port), "storage": Json(config.storage),
        "security": Json(security.mode), "aiApi": Json(config.aiApiPath), "odata": Json(config.odataPath),
        "fiori": Json(frontend.available ? "/app/index.html" : ""),
        "reconcileIntervalSeconds": Json(config.reconcileIntervalSeconds), "sources": Json(config.sources.map!(s => Json(s)).array)
      ]));
    return runApplication();
  }
}
