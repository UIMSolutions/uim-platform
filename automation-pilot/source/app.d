/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.automation_pilot;

void main() {
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Register all controllers
    container.catalogController.registerRoutes(router);
    container.commandController.registerRoutes(router);
    container.commandInputController.registerRoutes(router);
    container.executionController.registerRoutes(router);
    container.scheduledExecutionController.registerRoutes(router);
    container.triggerController.registerRoutes(router);
    container.serviceAccountController.registerRoutes(router);
    container.contentConnectorController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    writeln("====================================================");
    writeln("  Automation Pilot Service");
    writeln("====================================================");
    writeln("  Endpoints:");
    writeln("    GET    /api/v1/automation-pilot/catalogs");
    writeln("    POST   /api/v1/automation-pilot/catalogs");
    writeln("    GET    /api/v1/automation-pilot/catalogs/:id");
    writeln("    PUT    /api/v1/automation-pilot/catalogs/:id");
    writeln("    DELETE /api/v1/automation-pilot/catalogs/:id");
    writeln("    GET    /api/v1/automation-pilot/commands");
    writeln("    POST   /api/v1/automation-pilot/commands");
    writeln("    GET    /api/v1/automation-pilot/commands/:id");
    writeln("    PUT    /api/v1/automation-pilot/commands/:id");
    writeln("    DELETE /api/v1/automation-pilot/commands/:id");
    writeln("    GET    /api/v1/automation-pilot/inputs");
    writeln("    POST   /api/v1/automation-pilot/inputs");
    writeln("    GET    /api/v1/automation-pilot/inputs/:id");
    writeln("    PUT    /api/v1/automation-pilot/inputs/:id");
    writeln("    DELETE /api/v1/automation-pilot/inputs/:id");
    writeln("    GET    /api/v1/automation-pilot/executions");
    writeln("    POST   /api/v1/automation-pilot/executions");
    writeln("    GET    /api/v1/automation-pilot/executions/:id");
    writeln("    PUT    /api/v1/automation-pilot/executions/:id");
    writeln("    DELETE /api/v1/automation-pilot/executions/:id");
    writeln("    GET    /api/v1/automation-pilot/scheduled-executions");
    writeln("    POST   /api/v1/automation-pilot/scheduled-executions");
    writeln("    GET    /api/v1/automation-pilot/scheduled-executions/:id");
    writeln("    PUT    /api/v1/automation-pilot/scheduled-executions/:id");
    writeln("    DELETE /api/v1/automation-pilot/scheduled-executions/:id");
    writeln("    GET    /api/v1/automation-pilot/triggers");
    writeln("    POST   /api/v1/automation-pilot/triggers");
    writeln("    GET    /api/v1/automation-pilot/triggers/:id");
    writeln("    PUT    /api/v1/automation-pilot/triggers/:id");
    writeln("    DELETE /api/v1/automation-pilot/triggers/:id");
    writeln("    GET    /api/v1/automation-pilot/service-accounts");
    writeln("    POST   /api/v1/automation-pilot/service-accounts");
    writeln("    GET    /api/v1/automation-pilot/service-accounts/:id");
    writeln("    PUT    /api/v1/automation-pilot/service-accounts/:id");
    writeln("    DELETE /api/v1/automation-pilot/service-accounts/:id");
    writeln("    GET    /api/v1/automation-pilot/content-connectors");
    writeln("    POST   /api/v1/automation-pilot/content-connectors");
    writeln("    GET    /api/v1/automation-pilot/content-connectors/:id");
    writeln("    PUT    /api/v1/automation-pilot/content-connectors/:id");
    writeln("    DELETE /api/v1/automation-pilot/content-connectors/:id");
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
