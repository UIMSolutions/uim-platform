/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// HTTP server entry point (composition root): REST /api/v1, vibe.d REST
/// interface /rest/v1/identity-authentication, OData v4 and the Fiori app.
module app;

import uim.platform.identity_authentication;

@safe:

version (unittest) {
} else {
  void main() {
    auto config = loadConfig();
    configureLogging(config.logLevel);
    auto container = buildContainer(config);
    auto ports = container.ports;
    auto verifier = container.tokenSigner;
    auto api = config.apiPath;
    auto tenant = config.defaultTenant;

    auto router = new URLRouter();

    // ── REST driving adapters (/api/v1/…) ─────────────────────────────────
    new AuthController(ports.authentication, ports.tokens, api, tenant, config.issuer, verifier).registerRoutes(router);
    new UserController(ports.users, ports.sessions, api, tenant, verifier).registerRoutes(router);
    new GroupController(ports.groups, api, tenant, verifier).registerRoutes(router);
    new ApplicationController(ports.applications, api, tenant, verifier).registerRoutes(router);
    new PolicyController(ports.policies, api, tenant, verifier).registerRoutes(router);
    new RiskRuleController(ports.riskRules, api, tenant, verifier).registerRoutes(router);
    new IdentityProviderController(ports.identityProviders, api, tenant, verifier).registerRoutes(router);
    new SessionController(ports.sessions, api, tenant, verifier).registerRoutes(router);
    new TokenController(ports.tokens, api, tenant, verifier).registerRoutes(router);
    new StatisticsController(ports.statistics, api, tenant, verifier).registerRoutes(router);
    new HealthController(config.serviceName).registerRoutes(router);

    // ── vibe.d REST interface (/rest/v1/identity-authentication/users) ────
    router.registerRestInterface(new UserRestService(ports.users), config.restPath.stripRight("/") ~ "/users");

    // ── OData v4 driving adapter (SAP Fiori) ──────────────────────────────
    new IdentityODataController(ports, config.odataPath, tenant, verifier).registerRoutes(router);

    // ── Fiori app for local development (approuter serves it on CF) ───────
    auto frontend = new FrontendController(config.frontendDir);
    frontend.registerRoutes(router);

    // ── Background worker ─────────────────────────────────────────────────
    auto cleanup = new ExpiryCleanupWorker(ports.sessions, ports.tokens, config.cleanupTenants);
    cleanup.start(config.cleanupIntervalMinutes);

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];
    auto listener = listenHTTP(settings, router);
    scope (exit)
      listener.stopListening();

    logInfo("%s listening on %s:%d (storage=%s, config from %s)", config.serviceName,
      config.host, config.port, config.storage, config.sources.join(" → "));
    logInfo("  Auth   %s/auth/{login,logout,token,refresh,introspect,revoke,userinfo}", api);
    logInfo("  REST   %s/{users,groups,applications,policies,risk-rules,identity-providers,sessions,tokens,statistics}", api);
    logInfo("  REST   %s/users  (vibe.d REST interface)", config.restPath);
    logInfo("  OData  %s  ($metadata)", config.odataPath);
    logInfo("  OIDC   /.well-known/openid-configuration");
    logInfo("  Health /api/v1/health");
    if (frontend.available)
      logInfo("  Fiori  /index.html  (%s)", config.frontendDir);

    runApplication();
  }
}
