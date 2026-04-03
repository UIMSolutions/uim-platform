module app;

// import std.stdio;
// import std.conv;
import uim.platform.identity_authentication;
import uim.platform.identity_authentication.infrastructure.config;
import uim.platform.identity_authentication.infrastructure.container;
// import vibe.d;
@safe:

version (unittest) {
} else {
void main() {
    // Load configuration
    auto config = loadConfig();

    // Build dependency injection container (hexagonal wiring)
    auto container = buildContainer(config);

    // Configure vibe.d HTTP server
    auto router = new URLRouter();

    // Register all controller routes (driving adapters)
    container.authController.registerRoutes(router);
    container.userController.registerRoutes(router);
    container.groupController.registerRoutes(router);
    container.applicationController.registerRoutes(router);
    container.tenantController.registerRoutes(router);
    container.policyController.registerRoutes(router);

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];

    auto listener = listenHTTP(settings, router);

    writefln("╔══════════════════════════════════════════════════╗");
    writefln("║  Identity Authentication Service                ║");
    writefln("║  Listening on %s:%d                       ║", config.host, config.port);
    writefln("║                                                  ║");
    writefln("║  Endpoints:                                      ║");
    writefln("║    POST /api/v1/auth/login                       ║");
    writefln("║    POST /api/v1/auth/token                       ║");
    writefln("║    GET  /api/v1/auth/health                      ║");
    writefln("║    CRUD /api/v1/users                            ║");
    writefln("║    CRUD /api/v1/groups                           ║");
    writefln("║    CRUD /api/v1/applications                     ║");
    writefln("║    CRUD /api/v1/tenants                          ║");
    writefln("║    CRUD /api/v1/policies                         ║");
    writefln("╚══════════════════════════════════════════════════╝");

    runApplication();
}
