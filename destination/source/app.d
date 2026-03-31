module app;

import vibe.http.server;
import vibe.http.router;
import vibe.core.core : runApplication;

import infrastructure.config;
import infrastructure.container;

import std.stdio : writefln;

void main()
{
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Register all controller routes (driving adapters)
    container.findController.registerRoutes(router);        // Must be before wildcard destinations route
    container.destinationController.registerRoutes(router);
    container.certificateController.registerRoutes(router);
    container.fragmentController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];

    auto listener = listenHTTP(settings, router);

    writefln("==========================================================");
    writefln("  Destination Service");
    writefln("  Listening on %s:%d", config.host, config.port);
    writefln("                                                          ");
    writefln("  Endpoints:                                              ");
    writefln("    CRUD      /api/v1/destinations                        ");
    writefln("    GET       /api/v1/destinations/find?name=<name>       ");
    writefln("    CRUD      /api/v1/certificates                        ");
    writefln("    GET       /api/v1/certificates/expiring               ");
    writefln("    POST      /api/v1/certificates/validate/{id}          ");
    writefln("    CRUD      /api/v1/fragments                           ");
    writefln("    GET       /api/v1/health                              ");
    writefln("==========================================================");

    runApplication();
}
