module app;

import vibe.http.server;
import vibe.http.router;
import vibe.core.core : runApplication;

import infrastructure.config;
import infrastructure.container;

import std.stdio : writefln;

void main()
{
    // Load configuration
    auto config = loadConfig();

    // Build dependency injection container (hexagonal wiring)
    auto container = buildContainer(config);

    // Configure vibe.d HTTP server
    auto router = new URLRouter();

    // Register all controller routes (driving adapters)
    container.userController.registerRoutes(router);
    container.groupController.registerRoutes(router);
    container.schemaController.registerRoutes(router);
    container.passwordPolicyController.registerRoutes(router);
    container.apiClientController.registerRoutes(router);
    container.auditController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];

    auto listener = listenHTTP(settings, router);

    writefln("╔══════════════════════════════════════════════════════╗");
    writefln("║  Identity Directory Service                         ║");
    writefln("║  Listening on %s:%d                            ║", config.host, config.port);
    writefln("║                                                      ║");
    writefln("║  SCIM 2.0 Endpoints:                                 ║");
    writefln("║    CRUD /scim/Users                                  ║");
    writefln("║    CRUD /scim/Groups                                 ║");
    writefln("║    CRUD /scim/Schemas                                ║");
    writefln("║     GET /scim/Users/.search                          ║");
    writefln("║                                                      ║");
    writefln("║  Management Endpoints:                               ║");
    writefln("║    CRUD /api/v1/password-policies                    ║");
    writefln("║    CRUD /api/v1/api-clients                          ║");
    writefln("║     GET /api/v1/audit-logs                           ║");
    writefln("║     GET /api/v1/health                               ║");
    writefln("╚══════════════════════════════════════════════════════╝");

    runApplication();
}
