/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// HTTP server entry point (composition root):
///   REST    /api/v1/ai-launchpad/...       (resources, launchpad, operations)
///   OData   /odata/v4/ai-launchpad         ($metadata, $batch — SAP Fiori)
///   Fiori   /app/index.html                (launchpad; local development, approuter on BTP)
///   Auth    /auth/config, /auth/login, /auth/me, /auth/password, /auth/logout (built-in JWT login)
///   Health  /health, /api/v1/health
module app;

import uim.platform.ai_launchpad;

@safe:

version (unittest) {
} else {
  int main() {
    auto config = loadAilpConfig();
    auto container = new AilpContainer(config);
    auto security = container.security;
    container.engine.enforceScopes = security.requireAuthentication;
    foreach (tenant; tenantsToBootstrap(config))
      container.bootstrapTenant(tenant);
    if (security.mode == "jwt")
      bootstrapLogin(container);

    auto router = new URLRouter;
    new AilpHealthController(config, security.mode, container.runtime.mode, container.metrics)
      .registerRoutes(router, config.apiPath);
    new AuthController(container.ports, security).registerRoutes(router);
    new AilpApiController(container.engine, container.ports, security, config.apiPath, config.serviceVersion,
      config.maxRequestBytes, capabilitiesJson(container.runtime.mode, config.policy)).registerRoutes(router);

    auto odata = new ODataController(container.engine, config.odataPath, config.defaultTenant);
    odata.verifier = security.verifier;
    odata.requireAuthentication = security.requireAuthentication;
    odata.maxBodySize = config.maxRequestBytes;
    odata.registerRoutes(router);

    auto frontend = new FrontendController(config.frontendDir);
    frontend.registerRoutes(router);

    auto worker = new HousekeepingWorker(container.ports, config.workerTenants, config.purgeEveryRuns, container.metrics);
    worker.start(config.reconcileIntervalSeconds);

    auto settings = new HTTPServerSettings;
    settings.port = config.port;
    settings.bindAddresses = [config.host];
    settings.maxRequestSize = config.maxRequestBytes;
    auto listener = listenHTTP(settings, withRequestLogging(&router.handleRequest, config.serviceName));
    scope (exit)
      listener.stopListening();

    container.audit.record("service.started", TenantId(config.defaultTenant), UserId(systemActor), config.serviceName,
      Json(["version": Json(config.serviceVersion), "security": Json(security.mode)]));
    logServiceEvent("info", "listening", Json([
        "host": Json(config.host), "port": Json(config.port), "storage": Json(config.storage),
        "security": Json(security.mode), "api": Json(config.apiPath ~ "/ai-launchpad"),
        "odata": Json(config.odataPath), "launchpad": Json(frontend.available ? "/app/index.html" : ""),
        "runtime": Json(container.runtime.mode), "reconcileIntervalSeconds": Json(config.reconcileIntervalSeconds),
        "sources": Json(config.sources.map!(s => Json(s)).array)
      ]));
    return runApplication();
  }

  /// The default tenant and the worker tenants get the built-in roles and the default tiles.
  string[] tenantsToBootstrap(const AilpConfig config) {
    string[] tenants = [config.defaultTenant];
    foreach (t; config.workerTenants)
      if (!tenants.canFind(t))
        tenants ~= t;
    return tenants;
  }

  /// jwt mode: warn about a generated secret, create the first administrator.
  void bootstrapLogin(AilpContainer container) {
    auto config = container.config;
    if (container.security.generatedSecret)
      logServiceEvent("warning", "no jwtSecret configured: using a random secret, tokens end with this process",
        Json(["hint": Json("set AILP_JWT_SECRET (>= 32 characters)")]));
    auto password = config.adminPassword;
    auto generated = password.length == 0;
    if (generated)
      password = randomToken(12);
    if (container.ports.users.ensureAdministrator(TenantId(config.defaultTenant), config.adminUser, password))
      logServiceEvent("warning", "created the administrator of the built-in login", Json([
          "tenant": Json(config.defaultTenant), "user": Json(config.adminUser),
          "password": Json(generated ? password : "(from adminPassword)"),
          "hint": Json("change it: POST /auth/password or uim-ai-launchpad-cli passwd")
        ]));
  }
}
