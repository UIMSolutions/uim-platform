/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.datasphere.infrastructure.config;
import uim.platform.datasphere.infrastructure.container;

@safe:

version (unittest) {
} else {
    void main() {
        auto config = loadConfig();
        auto container = buildContainer(config);

        auto router = new URLRouter();

        // Register all controller routes (driving adapters)
        container.spaceController.registerRoutes(router);
        container.connectionController.registerRoutes(router);
        container.remoteTableController.registerRoutes(router);
        container.dataFlowController.registerRoutes(router);
        container.viewController.registerRoutes(router);
        container.taskController.registerRoutes(router);
        container.taskChainController.registerRoutes(router);
        container.dataAccessControlController.registerRoutes(router);
        container.catalogAssetController.registerRoutes(router);
        container.healthController.registerRoutes(router);

        auto settings = new HTTPServerSettings();
        settings.port = config.port;
        settings.bindAddresses = [config.host];

        auto listener = listenHTTP(settings, router);

        writefln("==========================================================");
        writefln("  Datasphere Service");
        writefln("  Listening on %s:%d", config.host, config.port);
        writefln("                                                          ");
        writefln("  Datasphere API v1 Endpoints:                            ");
        writefln("    CRUD      /api/v1/datasphere/spaces                   ");
        writefln("    CRUD      /api/v1/datasphere/connections              ");
        writefln("    CRUD      /api/v1/datasphere/remoteTables             ");
        writefln("    CRUD      /api/v1/datasphere/dataFlows                ");
        writefln("    CRUD      /api/v1/datasphere/views                    ");
        writefln("    CRUD      /api/v1/datasphere/tasks                    ");
        writefln("    CRUD      /api/v1/datasphere/taskChains               ");
        writefln("    CRUD      /api/v1/datasphere/dataAccessControls       ");
        writefln("    CRUD+Search /api/v1/datasphere/catalog                ");
        writefln("                                                          ");
        writefln("  Health:                                                 ");
        writefln("    GET       /api/v1/health                              ");
        writefln("==========================================================");

        runApplication();
    }
}
