/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.network_asset_collaboration;

void main() {
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Register all controllers
    container.equipmentController.registerRoutes(router);
    container.modelController.registerRoutes(router);
    container.companyProfileController.registerRoutes(router);
    container.documentController.registerRoutes(router);
    container.announcementController.registerRoutes(router);
    container.failureModeController.registerRoutes(router);
    container.sparePartController.registerRoutes(router);
    container.indicatorController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    writeln("====================================================");
    writeln("  Network Asset Collaboration Service");
    writeln("====================================================");
    writeln("  Endpoints:");
    writeln("    GET    /api/v1/network-asset-collaboration/equipment");
    writeln("    POST   /api/v1/network-asset-collaboration/equipment");
    writeln("    GET    /api/v1/network-asset-collaboration/equipment/:id");
    writeln("    PUT    /api/v1/network-asset-collaboration/equipment/:id");
    writeln("    DELETE /api/v1/network-asset-collaboration/equipment/:id");
    writeln("    GET    /api/v1/network-asset-collaboration/models");
    writeln("    POST   /api/v1/network-asset-collaboration/models");
    writeln("    GET    /api/v1/network-asset-collaboration/models/:id");
    writeln("    PUT    /api/v1/network-asset-collaboration/models/:id");
    writeln("    DELETE /api/v1/network-asset-collaboration/models/:id");
    writeln("    GET    /api/v1/network-asset-collaboration/companies");
    writeln("    POST   /api/v1/network-asset-collaboration/companies");
    writeln("    GET    /api/v1/network-asset-collaboration/companies/:id");
    writeln("    PUT    /api/v1/network-asset-collaboration/companies/:id");
    writeln("    DELETE /api/v1/network-asset-collaboration/companies/:id");
    writeln("    GET    /api/v1/network-asset-collaboration/documents");
    writeln("    POST   /api/v1/network-asset-collaboration/documents");
    writeln("    GET    /api/v1/network-asset-collaboration/documents/:id");
    writeln("    PUT    /api/v1/network-asset-collaboration/documents/:id");
    writeln("    DELETE /api/v1/network-asset-collaboration/documents/:id");
    writeln("    GET    /api/v1/network-asset-collaboration/announcements");
    writeln("    POST   /api/v1/network-asset-collaboration/announcements");
    writeln("    GET    /api/v1/network-asset-collaboration/announcements/:id");
    writeln("    PUT    /api/v1/network-asset-collaboration/announcements/:id");
    writeln("    DELETE /api/v1/network-asset-collaboration/announcements/:id");
    writeln("    GET    /api/v1/network-asset-collaboration/failure-modes");
    writeln("    POST   /api/v1/network-asset-collaboration/failure-modes");
    writeln("    GET    /api/v1/network-asset-collaboration/failure-modes/:id");
    writeln("    PUT    /api/v1/network-asset-collaboration/failure-modes/:id");
    writeln("    DELETE /api/v1/network-asset-collaboration/failure-modes/:id");
    writeln("    GET    /api/v1/network-asset-collaboration/spare-parts");
    writeln("    POST   /api/v1/network-asset-collaboration/spare-parts");
    writeln("    GET    /api/v1/network-asset-collaboration/spare-parts/:id");
    writeln("    PUT    /api/v1/network-asset-collaboration/spare-parts/:id");
    writeln("    DELETE /api/v1/network-asset-collaboration/spare-parts/:id");
    writeln("    GET    /api/v1/network-asset-collaboration/indicators");
    writeln("    POST   /api/v1/network-asset-collaboration/indicators");
    writeln("    GET    /api/v1/network-asset-collaboration/indicators/:id");
    writeln("    DELETE /api/v1/network-asset-collaboration/indicators/:id");
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
