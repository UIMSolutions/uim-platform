/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// HTTP server entry point (composition root):
///   OAuth   /oauth/authorize, /oauth/token, /oauth/introspect, /oauth/revoke
///           /.well-known/oauth-authorization-server
///   REST    /api/v1/oauth/...
///   OData   /odata/v4/oauth  ($metadata, $batch — SAP Fiori)
///   Fiori   /app/index.html  (local development; approuter on BTP)
///   Health  /health
module app;

import uim.platform.oauth;

@safe:

version (unittest) {
} else {
  int main() {
    auto config = loadOAuthConfig();
    auto container = new OAuthContainer(config);
    auto security = configureSecurity(config);
    container.engine.enforceScopes = security.requireAuthentication;

    auto router = new URLRouter;
    new OAuthHealthController(config, security.mode, container.signingKey.source).registerRoutes(router, config.restPath);
    new OAuthProtocolController(container.ports, security, config).registerRoutes(router);
    new OAuthRestController(container.engine, security, config.restPath).registerRoutes(router);

    auto odata = new ODataController(container.engine, config.odataPath, config.defaultTenant);
    odata.verifier = security.verifier;
    odata.requireAuthentication = security.requireAuthentication;
    odata.registerRoutes(router);

    auto frontend = new FrontendController(config.frontendDir);
    frontend.registerRoutes(router);

    auto purge = new ExpiryPurgeWorker(container.ports.tokens, config.purgeTenants);
    purge.start(config.purgeIntervalSeconds);

    auto settings = new HTTPServerSettings;
    settings.port = config.port;
    settings.bindAddresses = [config.host];
    settings.maxRequestSize = 4 * 1024 * 1024;
    auto listener = listenHTTP(settings, withRequestLogging(&router.handleRequest, config.serviceName));
    scope (exit)
      listener.stopListening();

    if (config.trustUserHeader)
      logServiceEvent("warn", "trustUserHeader is enabled: /oauth/authorize trusts X-User-Id — development only");
    if (container.signingKey.source != "configuration")
      logServiceEvent("warn", "no signingSecret configured; using a generated key kept in the document store", Json([
          "storage": Json(config.storage)
        ]));
    logServiceEvent("info", "listening", Json([
        "host": Json(config.host), "port": Json(config.port), "storage": Json(config.storage),
        "security": Json(security.mode), "issuer": Json(config.issuer), "oauth": Json(config.oauthPath),
        "rest": Json(config.restPath), "odata": Json(config.odataPath),
        "fiori": Json(frontend.available ? "/app/index.html" : ""), "purgeIntervalSeconds": Json(config.purgeIntervalSeconds)
      ]));
    return runApplication();
  }
}
