/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.oauth;

void main() {
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Register all controllers
    container.oauthClientController.registerRoutes(router);
    container.oauthScopeController.registerRoutes(router);
    container.accessTokenController.registerRoutes(router);
    container.refreshTokenController.registerRoutes(router);
    container.authorizationCodeController.registerRoutes(router);
    container.brandingConfigController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    writeln("====================================================");
    writeln("  OAuth 2.0 Service");
    writeln("====================================================");
    writeln("  Endpoints:");
    writeln("    GET    /api/v1/oauth/clients");
    writeln("    POST   /api/v1/oauth/clients");
    writeln("    GET    /api/v1/oauth/clients/:id");
    writeln("    PUT    /api/v1/oauth/clients/:id");
    writeln("    DELETE /api/v1/oauth/clients/:id");
    writeln("    GET    /api/v1/oauth/scopes");
    writeln("    POST   /api/v1/oauth/scopes");
    writeln("    GET    /api/v1/oauth/scopes/:id");
    writeln("    PUT    /api/v1/oauth/scopes/:id");
    writeln("    DELETE /api/v1/oauth/scopes/:id");
    writeln("    GET    /api/v1/oauth/access-tokens");
    writeln("    POST   /api/v1/oauth/access-tokens");
    writeln("    GET    /api/v1/oauth/access-tokens/:id");
    writeln("    POST   /api/v1/oauth/access-tokens/revoke/:id");
    writeln("    DELETE /api/v1/oauth/access-tokens/:id");
    writeln("    GET    /api/v1/oauth/refresh-tokens");
    writeln("    POST   /api/v1/oauth/refresh-tokens");
    writeln("    GET    /api/v1/oauth/refresh-tokens/:id");
    writeln("    POST   /api/v1/oauth/refresh-tokens/revoke/:id");
    writeln("    DELETE /api/v1/oauth/refresh-tokens/:id");
    writeln("    GET    /api/v1/oauth/authorization-codes");
    writeln("    POST   /api/v1/oauth/authorization-codes");
    writeln("    GET    /api/v1/oauth/authorization-codes/:id");
    writeln("    POST   /api/v1/oauth/authorization-codes/use/:id");
    writeln("    DELETE /api/v1/oauth/authorization-codes/:id");
    writeln("    GET    /api/v1/oauth/branding-configs");
    writeln("    POST   /api/v1/oauth/branding-configs");
    writeln("    GET    /api/v1/oauth/branding-configs/:id");
    writeln("    PUT    /api/v1/oauth/branding-configs/:id");
    writeln("    DELETE /api/v1/oauth/branding-configs/:id");
    writeln("    GET    /health");
    writeln("====================================================");
    writefln("  Listening on %s:%d", config.host, config.port);
    writeln("====================================================");

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];
    auto listener = listenHTTP(settings, router);
    scope (exit) listener.stopListening();
    runApplication();
}
