/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.core.core : runApplication;

import uim.platform.destination.infrastructure.config;
import uim.platform.destination.infrastructure.container;

// import std.stdio : writefln;

@safe:

version (unittest) {
}
else {
  void main() {
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Register all controller routes (driving adapters)
    container.findController.registerRoutes(router); // Must be before wildcard destinations route
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
}
