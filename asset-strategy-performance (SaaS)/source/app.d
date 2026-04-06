/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.asset_strategy_performance;

void main() {
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Register all controllers
    container.equipmentController.registerRoutes(router);
    container.modelController.registerRoutes(router);
    container.locationController.registerRoutes(router);
    container.failureModeController.registerRoutes(router);
    container.assessmentController.registerRoutes(router);
    container.instructionController.registerRoutes(router);
    container.functionController.registerRoutes(router);
    container.indicatorController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    writeln("====================================================");
    writeln("  Asset Strategy and Performance Management Service");
    writeln("====================================================");
    writeln("  Endpoints:");
    writeln("    GET    /api/v1/asset-strategy-performance/equipment");
    writeln("    POST   /api/v1/asset-strategy-performance/equipment");
    writeln("    GET    /api/v1/asset-strategy-performance/equipment/:id");
    writeln("    PUT    /api/v1/asset-strategy-performance/equipment/:id");
    writeln("    DELETE /api/v1/asset-strategy-performance/equipment/:id");
    writeln("    GET    /api/v1/asset-strategy-performance/models");
    writeln("    POST   /api/v1/asset-strategy-performance/models");
    writeln("    GET    /api/v1/asset-strategy-performance/models/:id");
    writeln("    PUT    /api/v1/asset-strategy-performance/models/:id");
    writeln("    DELETE /api/v1/asset-strategy-performance/models/:id");
    writeln("    GET    /api/v1/asset-strategy-performance/locations");
    writeln("    POST   /api/v1/asset-strategy-performance/locations");
    writeln("    GET    /api/v1/asset-strategy-performance/locations/:id");
    writeln("    PUT    /api/v1/asset-strategy-performance/locations/:id");
    writeln("    DELETE /api/v1/asset-strategy-performance/locations/:id");
    writeln("    GET    /api/v1/asset-strategy-performance/failure-modes");
    writeln("    POST   /api/v1/asset-strategy-performance/failure-modes");
    writeln("    GET    /api/v1/asset-strategy-performance/failure-modes/:id");
    writeln("    PUT    /api/v1/asset-strategy-performance/failure-modes/:id");
    writeln("    DELETE /api/v1/asset-strategy-performance/failure-modes/:id");
    writeln("    GET    /api/v1/asset-strategy-performance/assessments");
    writeln("    POST   /api/v1/asset-strategy-performance/assessments");
    writeln("    GET    /api/v1/asset-strategy-performance/assessments/:id");
    writeln("    PUT    /api/v1/asset-strategy-performance/assessments/:id");
    writeln("    DELETE /api/v1/asset-strategy-performance/assessments/:id");
    writeln("    GET    /api/v1/asset-strategy-performance/instructions");
    writeln("    POST   /api/v1/asset-strategy-performance/instructions");
    writeln("    GET    /api/v1/asset-strategy-performance/instructions/:id");
    writeln("    PUT    /api/v1/asset-strategy-performance/instructions/:id");
    writeln("    DELETE /api/v1/asset-strategy-performance/instructions/:id");
    writeln("    GET    /api/v1/asset-strategy-performance/functions");
    writeln("    POST   /api/v1/asset-strategy-performance/functions");
    writeln("    GET    /api/v1/asset-strategy-performance/functions/:id");
    writeln("    PUT    /api/v1/asset-strategy-performance/functions/:id");
    writeln("    DELETE /api/v1/asset-strategy-performance/functions/:id");
    writeln("    GET    /api/v1/asset-strategy-performance/indicators");
    writeln("    POST   /api/v1/asset-strategy-performance/indicators");
    writeln("    GET    /api/v1/asset-strategy-performance/indicators/:id");
    writeln("    DELETE /api/v1/asset-strategy-performance/indicators/:id");
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
