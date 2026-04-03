module app;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.core.core : runApplication;

import uim.platform.content_agent.infrastructure.config;
import uim.platform.content_agent.infrastructure.container;

// import std.stdio : writefln;
@safe:

version (unittest) {
} else {
void main() {
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Register all controller routes (driving adapters)
    container.packageController.registerRoutes(router);
    container.providerController.registerRoutes(router);
    container.transportController.registerRoutes(router);
    container.exportController.registerRoutes(router);
    container.importController.registerRoutes(router);
    container.queueController.registerRoutes(router);
    container.activityController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];

    auto listener = listenHTTP(settings, router);

    writefln("==========================================================");
    writefln("  Content Agent Service");
    writefln("  Listening on %s:%d", config.host, config.port);
    writefln("                                                          ");
    writefln("  Endpoints:                                              ");
    writefln("    CRUD      /api/v1/packages                            ");
    writefln("    POST      /api/v1/packages/assemble                   ");
    writefln("    CRUD      /api/v1/providers                           ");
    writefln("    POST      /api/v1/providers/sync                      ");
    writefln("    CRUD      /api/v1/transports                          ");
    writefln("    POST      /api/v1/transports/release                  ");
    writefln("    POST      /api/v1/transports/cancel                   ");
    writefln("    POST/GET  /api/v1/exports                             ");
    writefln("    POST/GET  /api/v1/imports                             ");
    writefln("    CRUD      /api/v1/queues                              ");
    writefln("    GET       /api/v1/activities                          ");
    writefln("    GET       /api/v1/activities/summary                  ");
    writefln("    GET       /api/v1/health                              ");
    writefln("==========================================================");

    runApplication();
}
