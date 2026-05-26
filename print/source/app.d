/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.print;

@safe:
version (unittest) {
}
else {
  void main() {
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Register REST API controllers
    container.printQueueController.registerRoutes(router);
    container.printTaskController.registerRoutes(router);
    container.printerController.registerRoutes(router);
    container.printDocumentController.registerRoutes(router);
    container.printClientController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    // Register web UI routes
    container.printWebController.registerRoutes(router);

    writeln("====================================================");
    writeln("  UIM Print Platform Service");
    writeln("====================================================");
    writeln("  Cloud print queue and task management service");
    writeln("  modeled on SAP BTP Print Service.");
    writeln("  Backend: ", config.backend.to!string);
    writeln("  Port:    ", config.port);
    writeln("----------------------------------------------------");
    writeln("  REST API Endpoints:");
    writeln("    GET    /api/v1/health");
    writeln("    GET    /api/v1/print/queues");
    writeln("    POST   /api/v1/print/queues");
    writeln("    GET    /api/v1/print/queues/:id");
    writeln("    PUT    /api/v1/print/queues/:id");
    writeln("    DELETE /api/v1/print/queues/:id");
    writeln("    GET    /api/v1/print/tasks");
    writeln("    POST   /api/v1/print/tasks");
    writeln("    GET    /api/v1/print/tasks/:id");
    writeln("    PUT    /api/v1/print/tasks/:id");
    writeln("    DELETE /api/v1/print/tasks/:id");
    writeln("    GET    /api/v1/print/printers");
    writeln("    POST   /api/v1/print/printers");
    writeln("    GET    /api/v1/print/printers/:id");
    writeln("    PUT    /api/v1/print/printers/:id");
    writeln("    DELETE /api/v1/print/printers/:id");
    writeln("    GET    /api/v1/print/documents");
    writeln("    POST   /api/v1/print/documents");
    writeln("    GET    /api/v1/print/documents/:id");
    writeln("    DELETE /api/v1/print/documents/:id");
    writeln("    GET    /api/v1/print/clients");
    writeln("    POST   /api/v1/print/clients");
    writeln("    GET    /api/v1/print/clients/:id");
    writeln("    PUT    /api/v1/print/clients/:id");
    writeln("    DELETE /api/v1/print/clients/:id");
    writeln("----------------------------------------------------");
    writeln("  Web UI Endpoints:");
    writeln("    GET    /web/print/queues");
    writeln("    GET    /web/print/tasks");
    writeln("====================================================");

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];
    auto listener = listenHTTP(settings, router);
    scope (exit) listener.stopListening();
    runApplication();
  }
}
