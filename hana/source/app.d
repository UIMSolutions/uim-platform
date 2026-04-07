/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

// import uim.platform.hana.infrastructure.config;
// import uim.platform.hana.infrastructure.container;

// import std.stdio : writefln;
// import vibe.http.router : URLRouter;
// import vibe.http.server : HTTPServerSettings;
// import vibe.http.server : listenHTTP;
// import vibe.core.core : runApplication;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
version (unittest) {
} else {
    void main() {
        auto config = loadConfig();
        auto container = buildContainer(config);

        auto router = new URLRouter();

        // Register all controller routes (driving adapters)
        container.instanceController.registerRoutes(router);
        container.dataLakeController.registerRoutes(router);
        container.schemaController.registerRoutes(router);
        container.databaseUserController.registerRoutes(router);
        container.backupController.registerRoutes(router);
        container.alertController.registerRoutes(router);
        container.hdiContainerController.registerRoutes(router);
        container.replicationTaskController.registerRoutes(router);
        container.configurationController.registerRoutes(router);
        container.databaseConnectionController.registerRoutes(router);
        container.healthController.registerRoutes(router);

        auto settings = new HTTPServerSettings();
        settings.port = config.port;
        settings.bindAddresses = [config.host];

        auto listener = listenHTTP(settings, router);

        writefln("==========================================================");
        writefln("  HANA Cloud Service");
        writefln("  Listening on %s:%d", config.host, config.port);
        writefln("                                                          ");
        writefln("  HANA Cloud API v1 Endpoints:                            ");
        writefln("    CRUD+Action /api/v1/hana/instances                    ");
        writefln("    CRUD        /api/v1/hana/dataLakes                    ");
        writefln("    CRUD        /api/v1/hana/schemas                      ");
        writefln("    CRUD        /api/v1/hana/users                        ");
        writefln("    CRUD        /api/v1/hana/backups                      ");
        writefln("    CRUD+Ack    /api/v1/hana/alerts                       ");
        writefln("    CRUD        /api/v1/hana/hdiContainers                ");
        writefln("    CRUD        /api/v1/hana/replicationTasks             ");
        writefln("    CRUD        /api/v1/hana/configurations               ");
        writefln("    CRUD        /api/v1/hana/connections                  ");
        writefln("                                                          ");
        writefln("  Health:                                                 ");
        writefln("    GET         /api/v1/health                            ");
        writefln("==========================================================");

        runApplication();
    }
}
