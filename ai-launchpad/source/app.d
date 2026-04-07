/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.ai_launchpad.infrastructure.config;
import uim.platform.ai_launchpad.infrastructure.container;

@safe:

version (unittest) {
} else {
    void main() {
        auto config = loadConfig();
        auto container = buildContainer(config);

        auto router = new URLRouter();

        // Register all controller routes (driving adapters)
        container.connectionController.registerRoutes(router);
        container.workspaceController.registerRoutes(router);
        container.scenarioController.registerRoutes(router);
        container.configurationController.registerRoutes(router);
        container.executionController.registerRoutes(router);
        container.deploymentController.registerRoutes(router);
        container.modelController.registerRoutes(router);
        container.datasetController.registerRoutes(router);
        container.promptController.registerRoutes(router);
        container.promptCollectionController.registerRoutes(router);
        container.resourceGroupController.registerRoutes(router);
        container.statisticsController.registerRoutes(router);
        container.capabilitiesController.registerRoutes(router);
        container.healthController.registerRoutes(router);

        auto settings = new HTTPServerSettings();
        settings.port = config.port;
        settings.bindAddresses = [config.host];

        auto listener = listenHTTP(settings, router);

        writefln("==========================================================");
        writefln("  AI Launchpad Service");
        writefln("  Listening on %s:%d", config.host, config.port);
        writefln("                                                          ");
        writefln("  Connection + Workspace Management:                      ");
        writefln("    CRUD      /api/v1/connections                         ");
        writefln("    CRUD      /api/v1/workspaces                          ");
        writefln("                                                          ");
        writefln("  AI Lifecycle:                                           ");
        writefln("    SYNC+GET  /api/v1/scenarios                           ");
        writefln("    CRUD      /api/v1/configurations                      ");
        writefln("    CRUD+BULK /api/v1/executions                          ");
        writefln("    CRUD+BULK /api/v1/deployments                         ");
        writefln("    CRUD      /api/v1/models                              ");
        writefln("    CRUD      /api/v1/datasets                            ");
        writefln("                                                          ");
        writefln("  Generative AI Hub:                                      ");
        writefln("    CRUD      /api/v1/genai/prompts                       ");
        writefln("    CRUD      /api/v1/genai/prompt-collections            ");
        writefln("                                                          ");
        writefln("  Admin:                                                  ");
        writefln("    CRUD      /api/v1/admin/resource-groups               ");
        writefln("    GET       /api/v1/statistics                          ");
        writefln("    GET       /api/v1/capabilities                        ");
        writefln("                                                          ");
        writefln("  Health:                                                 ");
        writefln("    GET       /api/v1/health                              ");
        writefln("==========================================================");

        runApplication();
    }
}
