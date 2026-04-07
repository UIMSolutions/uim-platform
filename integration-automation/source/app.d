/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.core.core : runApplication;

import uim.platform.integration.automation.infrastructure.config;
import uim.platform.integration.automation.infrastructure.container;

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
    container.scenarioController.registerRoutes(router);
    container.workflowController.registerRoutes(router);
    container.stepController.registerRoutes(router);
    container.systemController.registerRoutes(router);
    container.destinationController.registerRoutes(router);
    container.monitoringController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];

    auto listener = listenHTTP(settings, router);

    writefln("==========================================================");
    writefln("  Integration Automation Service");
    writefln("  Listening on %s:%d", config.host, config.port);
    writefln("                                                          ");
    writefln("  Endpoints:                                              ");
    writefln("    CRUD      /api/v1/scenarios                           ");
    writefln("    CRUD      /api/v1/workflows                           ");
    writefln("              /api/v1/workflows/start|suspend|resume|terminate/*");
    writefln("    CRUD      /api/v1/steps                               ");
    writefln("              /api/v1/steps/start|complete|fail|skip/*     ");
    writefln("    GET       /api/v1/my-tasks                            ");
    writefln("    CRUD      /api/v1/systems                             ");
    writefln("              /api/v1/systems/test/*                       ");
    writefln("    CRUD      /api/v1/destinations                        ");
    writefln("    GET       /api/v1/monitoring/logs                      ");
    writefln("    GET       /api/v1/monitoring/failures                  ");
    writefln("    GET       /api/v1/monitoring/summary/*                 ");
    writefln("    GET       /api/v1/health                              ");
    writefln("==========================================================");

    runApplication();
  }
