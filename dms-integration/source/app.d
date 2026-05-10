/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.dms_integration;

@safe:

version (unittest) {
}
else {
  void main() {
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Register all controllers
    container.repositoryController.registerRoutes(router);
    container.documentController.registerRoutes(router);
    container.folderController.registerRoutes(router);
    container.documentVersionController.registerRoutes(router);
    container.permissionController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    writeln("====================================================");
    writeln("  DMS Integration Platform Service");
    writeln("====================================================");
    writeln("  Endpoints:");
    writeln("    GET    /api/v1/dms-integration/repositories");
    writeln("    POST   /api/v1/dms-integration/repositories");
    writeln("    GET    /api/v1/dms-integration/repositories/:id");
    writeln("    PUT    /api/v1/dms-integration/repositories/:id");
    writeln("    DELETE /api/v1/dms-integration/repositories/:id");
    writeln("    GET    /api/v1/dms-integration/documents");
    writeln("    POST   /api/v1/dms-integration/documents");
    writeln("    GET    /api/v1/dms-integration/documents/:id");
    writeln("    PUT    /api/v1/dms-integration/documents/:id");
    writeln("    DELETE /api/v1/dms-integration/documents/:id");
    writeln("    GET    /api/v1/dms-integration/folders");
    writeln("    POST   /api/v1/dms-integration/folders");
    writeln("    GET    /api/v1/dms-integration/folders/:id");
    writeln("    PUT    /api/v1/dms-integration/folders/:id");
    writeln("    DELETE /api/v1/dms-integration/folders/:id");
    writeln("    GET    /api/v1/dms-integration/document-versions");
    writeln("    POST   /api/v1/dms-integration/document-versions");
    writeln("    GET    /api/v1/dms-integration/document-versions/:id");
    writeln("    DELETE /api/v1/dms-integration/document-versions/:id");
    writeln("    GET    /api/v1/dms-integration/permissions");
    writeln("    POST   /api/v1/dms-integration/permissions");
    writeln("    GET    /api/v1/dms-integration/permissions/:id");
    writeln("    DELETE /api/v1/dms-integration/permissions/:id");
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
