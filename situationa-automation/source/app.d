/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
version (unittest) {
} ) {
    void main() {
        auto config = loadConfig();
        auto container = buildContainer(config);

        auto router = new URLRouter();

        // Register all controller routes (driving adapters)
        container.templateController.registerRoutes(router);
        container.instanceController.registerRoutes(router);
        container.actionController.registerRoutes(router);
        container.ruleController.registerRoutes(router);
        container.entityTypeController.registerRoutes(router);
        container.dataContextController.registerRoutes(router);
        container.notificationController.registerRoutes(router);
        container.dashboardController.registerRoutes(router);
        container.healthController.registerRoutes(router);

        auto settings = new HTTPServerSettings();
        settings.port = config.port;
        settings.bindAddresses = [config.host];

        auto listener = listenHTTP(settings, router);

        writefln("==========================================================");
        writefln("  Situation Automation Service");
        writefln("  Listening on %s:%d", config.host, config.port);
        writefln("                                                          ");
        writefln("  Situation Automation API v1 Endpoints:                  ");
        writefln("    CRUD   /api/v1/situation-automation/templates         ");
        writefln("    CRUD+R /api/v1/situation-automation/instances         ");
        writefln("    CRUD   /api/v1/situation-automation/actions           ");
        writefln("    CRUD   /api/v1/situation-automation/rules             ");
        writefln("    CRUD   /api/v1/situation-automation/entity-types      ");
        writefln("    CR+D   /api/v1/situation-automation/data-contexts     ");
        writefln("    CRUD   /api/v1/situation-automation/notifications     ");
        writefln("    CRUD   /api/v1/situation-automation/dashboards        ");
        writefln("                                                          ");
        writefln("  Health:                                                 ");
        writefln("    GET    /api/v1/health                                 ");
        writefln("==========================================================");

        runApplication();
    }
}
