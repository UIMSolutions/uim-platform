/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// HTTP server entry point (composition root):
///   REST    /api/v1/appevents/...        (resources, publishing, delivery)
///   OData   /odata/v4/appevents          ($metadata, $batch — SAP Fiori)
///   Fiori   /app/index.html              (local development; approuter on BTP)
///   Auth    /auth/config, /auth/login, /auth/me, /auth/password (built-in JWT login, authMode "jwt")
///   Health  /health, /api/v1/health
module app;

import uim.platform.application_events;

@safe:

version (unittest) {
} else {
  int main() {
    auto config = loadAehConfig();
    auto container = new AehContainer(config);
    auto security = container.security;
    container.engine.enforceScopes = security.requireAuthentication;
    if (security.mode == "jwt")
      bootstrapLogin(container);

    auto router = new URLRouter;
    new AehHealthController(config, security.mode, container.gateway.mode, container.metrics)
      .registerRoutes(router, config.apiPath);
    new AuthController(container.ports, security).registerRoutes(router);
    new AehApiController(container.engine, container.ports, security, config.policy, config.apiPath, config.serviceVersion,
      config.maxRequestBytes, capabilitiesJson(container.gateway.mode, config.policy)).registerRoutes(router);

    auto odata = new ODataController(container.engine, config.odataPath, config.defaultTenant);
    odata.verifier = security.verifier;
    odata.requireAuthentication = security.requireAuthentication;
    odata.maxBodySize = config.maxRequestBytes;
    odata.registerRoutes(router);

    auto frontend = new FrontendController(config.frontendDir);
    frontend.registerRoutes(router);

    auto worker = new DeliveryWorker(container.ports, config.workerTenants, config.purgeEveryRuns, container.metrics);
    worker.start(config.dispatchIntervalSeconds);

    auto settings = new HTTPServerSettings;
    settings.port = config.port;
    settings.bindAddresses = [config.host];
    settings.maxRequestSize = config.maxRequestBytes;
    auto listener = listenHTTP(settings, withRequestLogging(&router.handleRequest, config.serviceName));
    scope (exit)
      listener.stopListening();

    logServiceEvent("info", "listening", Json([
        "host": Json(config.host), "port": Json(config.port), "storage": Json(config.storage),
        "security": Json(security.mode), "api": Json(config.apiPath ~ "/appevents"),
        "odata": Json(config.odataPath), "fiori": Json(frontend.available ? "/app/index.html" : ""),
        "deliveryGateway": Json(container.gateway.mode),
        "dispatchIntervalSeconds": Json(config.dispatchIntervalSeconds),
        "sources": Json(config.sources.map!(s => Json(s)).array)
      ]));
    return runApplication();
  }

  /// jwt mode: warn about a generated secret, create the first administrator.
  void bootstrapLogin(AehContainer container) {
    auto config = container.config;
    if (container.security.generatedSecret)
      logServiceEvent("warning", "no jwtSecret configured: using a random secret, tokens end with this process",
        Json(["hint": Json("set APPEVENTS_JWT_SECRET (>= 32 characters)")]));
    auto password = config.adminPassword;
    auto generated = password.length == 0;
    if (generated)
      password = randomToken(12);
    if (container.ports.users.ensureAdministrator(TenantId(config.defaultTenant), config.adminUser, password))
      logServiceEvent("warning", "created the administrator of the built-in login", Json([
          "tenant": Json(config.defaultTenant), "user": Json(config.adminUser),
          "password": Json(generated ? password : "(from adminPassword)"),
          "hint": Json("change it: POST /auth/password or uim-application-events-cli passwd")
        ]));
  }
}
