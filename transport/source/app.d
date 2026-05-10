/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.transport;

@safe:

version (unittest) {
}
else {
  void main() {
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Register all controllers
    container.nodeController.registerRoutes(router);
    container.routeController.registerRoutes(router);
    container.requestController.registerRoutes(router);
    container.queueEntryController.registerRoutes(router);
    container.actionController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    writeln("====================================================");
    writeln("  Transport Platform Service");
    writeln("  SAP Cloud Transport Management (UIM Edition)");
    writeln("====================================================");
    writeln("  Endpoints:");
    writeln("    GET    /api/v1/transport/nodes");
    writeln("    POST   /api/v1/transport/nodes");
    writeln("    GET    /api/v1/transport/nodes/:id");
    writeln("    PUT    /api/v1/transport/nodes/:id");
    writeln("    DELETE /api/v1/transport/nodes/:id");
    writeln("    GET    /api/v1/transport/routes");
    writeln("    POST   /api/v1/transport/routes");
    writeln("    GET    /api/v1/transport/routes/:id");
    writeln("    PUT    /api/v1/transport/routes/:id");
    writeln("    DELETE /api/v1/transport/routes/:id");
    writeln("    GET    /api/v1/transport/requests");
    writeln("    POST   /api/v1/transport/requests");
    writeln("    GET    /api/v1/transport/requests/:id");
    writeln("    PUT    /api/v1/transport/requests/:id");
    writeln("    DELETE /api/v1/transport/requests/:id");
    writeln("    GET    /api/v1/transport/queue-entries");
    writeln("    POST   /api/v1/transport/queue-entries");
    writeln("    GET    /api/v1/transport/queue-entries/:id");
    writeln("    PUT    /api/v1/transport/queue-entries/:id");
    writeln("    DELETE /api/v1/transport/queue-entries/:id");
    writeln("    GET    /api/v1/transport/actions");
    writeln("    POST   /api/v1/transport/actions");
    writeln("    GET    /api/v1/transport/actions/:id");
    writeln("    PUT    /api/v1/transport/actions/:id");
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
}
