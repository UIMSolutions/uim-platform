/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// HTTP server entry point (composition root):
///   REST    /api/v1/document-ai/...      (resources and operations)
///   OData   /odata/v4/document-ai        ($metadata, $batch — SAP Fiori)
///   Fiori   /app/index.html              (local development; approuter on BTP)
///   Auth    /auth/config, /auth/login, /auth/me, /auth/password (built-in JWT login, authMode "jwt")
///   Health  /health, /api/v1/health
module app;

import uim.platform.document_ai;

@safe:

version (unittest) {
} else {
  int main() {
    auto config = loadDaiConfig();
    auto container = new DaiContainer(config);
    auto security = container.security;
    container.engine.enforceScopes = security.requireAuthentication;
    if (security.mode == "jwt")
      bootstrapLogin(container);

    auto router = new URLRouter;
    new DaiHealthController(config, security.mode, container.extraction.mode, container.metrics)
      .registerRoutes(router, config.apiPath);
    new AuthController(container.ports, security).registerRoutes(router);
    new DaiApiController(container.engine, security, config.apiPath, config.serviceVersion, config.maxRequestBytes,
      capabilitiesJson(container.extraction.mode, config.policy)).registerRoutes(router);

    auto odata = new ODataController(container.engine, config.odataPath, config.defaultTenant);
    odata.verifier = security.verifier;
    odata.requireAuthentication = security.requireAuthentication;
    odata.maxBodySize = config.maxRequestBytes;
    odata.registerRoutes(router);

    auto frontend = new FrontendController(config.frontendDir);
    frontend.registerRoutes(router);

    auto worker = new ProcessingWorker(container.ports, config.workerTenants, config.policy.maxDocumentsPerRun,
      container.metrics);
    worker.start(config.workerIntervalSeconds);

    auto settings = new HTTPServerSettings;
    settings.port = config.port;
    settings.bindAddresses = [config.host];
    settings.maxRequestSize = config.maxRequestBytes;
    auto listener = listenHTTP(settings, withRequestLogging(&router.handleRequest, config.serviceName));
    scope (exit)
      listener.stopListening();

    logServiceEvent("info", "listening", Json([
        "host": Json(config.host), "port": Json(config.port), "storage": Json(config.storage),
        "security": Json(security.mode), "api": Json(config.apiPath ~ "/document-ai"),
        "odata": Json(config.odataPath), "fiori": Json(frontend.available ? "/app/index.html" : ""),
        "extraction": Json(container.extraction.mode), "workerIntervalSeconds": Json(config.workerIntervalSeconds),
        "sources": Json(config.sources.map!(s => Json(s)).array)
      ]));
    return runApplication();
  }

  /// jwt mode: warn about a generated secret, create the first administrator.
  void bootstrapLogin(DaiContainer container) {
    auto config = container.config;
    if (container.security.generatedSecret)
      logServiceEvent("warning", "no jwtSecret configured: using a random secret, tokens end with this process",
        Json(["hint": Json("set DOCAI_JWT_SECRET (>= 32 characters)")]));
    auto password = config.adminPassword;
    auto generated = password.length == 0;
    if (generated)
      password = randomToken(12);
    if (container.ports.users.ensureAdministrator(TenantId(config.defaultTenant), config.adminUser, password))
      logServiceEvent("warning", "created the administrator of the built-in login", Json([
          "tenant": Json(config.defaultTenant), "user": Json(config.adminUser),
          "password": Json(generated ? password : "(from adminPassword)"),
          "hint": Json("change it: POST /auth/password or uim-document-ai-cli passwd")
        ]));
  }
}
