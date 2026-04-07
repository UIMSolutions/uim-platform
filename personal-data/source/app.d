/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:
version (unittest) {
} ) {
    void main() {
        auto config = loadConfig();
        auto container = buildContainer(config);

        auto router = new URLRouter();

        // Register all controller routes (driving adapters)
        container.subjectController.registerRoutes(router);
        container.requestController.registerRoutes(router);
        container.recordController.registerRoutes(router);
        container.applicationController.registerRoutes(router);
        container.purposeController.registerRoutes(router);
        container.consentController.registerRoutes(router);
        container.retentionController.registerRoutes(router);
        container.logController.registerRoutes(router);
        container.healthController.registerRoutes(router);

        auto settings = new HTTPServerSettings();
        settings.port = config.port;
        settings.bindAddresses = [config.host];

        auto listener = listenHTTP(settings, router);

        writefln("==========================================================");
        writefln("  Personal Data Manager Service");
        writefln("  Listening on %s:%d", config.host, config.port);
        writefln("                                                          ");
        writefln("  Personal Data API v1 Endpoints:                         ");
        writefln("    CRUD+BE /api/v1/personal-data/subjects                ");
        writefln("    GET     /api/v1/personal-data/subjects/search         ");
        writefln("    CRUD    /api/v1/personal-data/requests                ");
        writefln("    CR+D    /api/v1/personal-data/records                 ");
        writefln("    CRUD+AS /api/v1/personal-data/applications            ");
        writefln("    CRUD    /api/v1/personal-data/purposes                ");
        writefln("    CR+W+D  /api/v1/personal-data/consents               ");
        writefln("    CRUD    /api/v1/personal-data/retention-rules         ");
        writefln("    CR+D    /api/v1/personal-data/logs                    ");
        writefln("                                                          ");
        writefln("  Health:                                                 ");
        writefln("    GET     /api/v1/health                                ");
        writefln("==========================================================");

        runApplication();
    }
}
