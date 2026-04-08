/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.core.core : runApplication;

import uim.platform.connectivity.infrastructure.config;
import uim.platform.connectivity.infrastructure.container;

// import std.stdio : writefln;

import uim.platform.connectivity;

@safe:

version (unittest) {
}
else {
  void main() {
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Register all controller routes (driving adapters)
    container.destinationController.registerRoutes(router);
    container.connectorController.registerRoutes(router);
    container.channelController.registerRoutes(router);
    container.accessRuleController.registerRoutes(router);
    container.certificateController.registerRoutes(router);
    container.monitoringController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];

    auto listener = listenHTTP(settings, router);

    writefln("==========================================================");
    writefln("  Connectivity Service");
    writefln("  Listening on %s:%d", config.host, config.port);
    writefln("                                                          ");
    writefln("  Endpoints:                                              ");
    writefln("    CRUD      /api/v1/destinations                        ");
    writefln("    CRUD      /api/v1/connectors                          ");
    writefln("    CRUD      /api/v1/channels                            ");
    writefln("    CRUD      /api/v1/access-rules                        ");
    writefln("    CRUD      /api/v1/certificates                        ");
    writefln("    GET       /api/v1/monitoring/logs                      ");
    writefln("    GET       /api/v1/monitoring/summary                   ");
    writefln("    GET       /api/v1/health                              ");
    writefln("==========================================================");

    runApplication();
  }
