/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.field_service;

void main() {
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Register all controllers
    container.serviceCallController.registerRoutes(router);
    container.activityController.registerRoutes(router);
    container.assignmentController.registerRoutes(router);
    container.equipmentController.registerRoutes(router);
    container.technicianController.registerRoutes(router);
    container.customerController.registerRoutes(router);
    container.skillController.registerRoutes(router);
    container.smartformController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    writeln("====================================================");
    writeln("  Field Service Management");
    writeln("====================================================");
    writeln("  Endpoints:");
    writeln("    GET    /api/v1/field-service/service-calls");
    writeln("    POST   /api/v1/field-service/service-calls");
    writeln("    GET    /api/v1/field-service/service-calls/:id");
    writeln("    PUT    /api/v1/field-service/service-calls/:id");
    writeln("    DELETE /api/v1/field-service/service-calls/:id");
    writeln("    GET    /api/v1/field-service/activities");
    writeln("    POST   /api/v1/field-service/activities");
    writeln("    GET    /api/v1/field-service/activities/:id");
    writeln("    PUT    /api/v1/field-service/activities/:id");
    writeln("    DELETE /api/v1/field-service/activities/:id");
    writeln("    GET    /api/v1/field-service/assignments");
    writeln("    POST   /api/v1/field-service/assignments");
    writeln("    GET    /api/v1/field-service/assignments/:id");
    writeln("    PUT    /api/v1/field-service/assignments/:id");
    writeln("    DELETE /api/v1/field-service/assignments/:id");
    writeln("    GET    /api/v1/field-service/equipment");
    writeln("    POST   /api/v1/field-service/equipment");
    writeln("    GET    /api/v1/field-service/equipment/:id");
    writeln("    PUT    /api/v1/field-service/equipment/:id");
    writeln("    DELETE /api/v1/field-service/equipment/:id");
    writeln("    GET    /api/v1/field-service/technicians");
    writeln("    POST   /api/v1/field-service/technicians");
    writeln("    GET    /api/v1/field-service/technicians/:id");
    writeln("    PUT    /api/v1/field-service/technicians/:id");
    writeln("    DELETE /api/v1/field-service/technicians/:id");
    writeln("    GET    /api/v1/field-service/customers");
    writeln("    POST   /api/v1/field-service/customers");
    writeln("    GET    /api/v1/field-service/customers/:id");
    writeln("    PUT    /api/v1/field-service/customers/:id");
    writeln("    DELETE /api/v1/field-service/customers/:id");
    writeln("    GET    /api/v1/field-service/skills");
    writeln("    POST   /api/v1/field-service/skills");
    writeln("    GET    /api/v1/field-service/skills/:id");
    writeln("    PUT    /api/v1/field-service/skills/:id");
    writeln("    DELETE /api/v1/field-service/skills/:id");
    writeln("    GET    /api/v1/field-service/smartforms");
    writeln("    POST   /api/v1/field-service/smartforms");
    writeln("    GET    /api/v1/field-service/smartforms/:id");
    writeln("    PUT    /api/v1/field-service/smartforms/:id");
    writeln("    DELETE /api/v1/field-service/smartforms/:id");
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
