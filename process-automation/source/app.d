/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
version (unittest) {
} else {
    void main() {
        auto config = loadConfig();
        auto container = buildContainer(config);

        auto router = new URLRouter();

        // Register all controller routes (driving adapters)
        container.processController.registerRoutes(router);
        container.processInstanceController.registerRoutes(router);
        container.taskController.registerRoutes(router);
        container.decisionController.registerRoutes(router);
        container.formController.registerRoutes(router);
        container.automationController.registerRoutes(router);
        container.triggerController.registerRoutes(router);
        container.actionController.registerRoutes(router);
        container.visibilityController.registerRoutes(router);
        container.artifactController.registerRoutes(router);
        container.healthController.registerRoutes(router);

        auto settings = new HTTPServerSettings();
        settings.port = config.port;
        settings.bindAddresses = [config.host];

        auto listener = listenHTTP(settings, router);

        writefln("==========================================================");
        writefln("  Process Automation Service");
        writefln("  Listening on %s:%d", config.host, config.port);
        writefln("                                                          ");
        writefln("  Process Automation API v1 Endpoints:                    ");
        writefln("    CRUD+Deploy /api/v1/process-automation/processes      ");
        writefln("    CRUD+Action /api/v1/process-automation/instances      ");
        writefln("    CRUD+Claim  /api/v1/process-automation/tasks          ");
        writefln("    CRUD        /api/v1/process-automation/decisions      ");
        writefln("    CRUD        /api/v1/process-automation/forms          ");
        writefln("    CRUD        /api/v1/process-automation/automations    ");
        writefln("    CRUD        /api/v1/process-automation/triggers       ");
        writefln("    CRUD        /api/v1/process-automation/actions        ");
        writefln("    CRUD        /api/v1/process-automation/visibility     ");
        writefln("    CRUD        /api/v1/process-automation/store/artifacts");
        writefln("                                                          ");
        writefln("  Health:                                                 ");
        writefln("    GET         /api/v1/health                            ");
        writefln("==========================================================");

        runApplication();
    }
}
