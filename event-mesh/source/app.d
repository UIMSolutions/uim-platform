/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.event_mesh;

void main() {
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Register all controllers
    container.brokerServiceController.registerRoutes(router);
    container.queueController.registerRoutes(router);
    container.topicController.registerRoutes(router);
    container.subscriptionController.registerRoutes(router);
    container.eventMessageController.registerRoutes(router);
    container.eventSchemaController.registerRoutes(router);
    container.eventApplicationController.registerRoutes(router);
    container.meshBridgeController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    writeln("====================================================");
    writeln("  Event Mesh Service");
    writeln("====================================================");
    writeln("  Endpoints:");
    writeln("    GET    /api/v1/event-mesh/broker-services");
    writeln("    POST   /api/v1/event-mesh/broker-services");
    writeln("    GET    /api/v1/event-mesh/broker-services/:id");
    writeln("    PUT    /api/v1/event-mesh/broker-services/:id");
    writeln("    DELETE /api/v1/event-mesh/broker-services/:id");
    writeln("    GET    /api/v1/event-mesh/queues");
    writeln("    POST   /api/v1/event-mesh/queues");
    writeln("    GET    /api/v1/event-mesh/queues/:id");
    writeln("    PUT    /api/v1/event-mesh/queues/:id");
    writeln("    DELETE /api/v1/event-mesh/queues/:id");
    writeln("    GET    /api/v1/event-mesh/topics");
    writeln("    POST   /api/v1/event-mesh/topics");
    writeln("    GET    /api/v1/event-mesh/topics/:id");
    writeln("    PUT    /api/v1/event-mesh/topics/:id");
    writeln("    DELETE /api/v1/event-mesh/topics/:id");
    writeln("    GET    /api/v1/event-mesh/subscriptions");
    writeln("    POST   /api/v1/event-mesh/subscriptions");
    writeln("    GET    /api/v1/event-mesh/subscriptions/:id");
    writeln("    PUT    /api/v1/event-mesh/subscriptions/:id");
    writeln("    DELETE /api/v1/event-mesh/subscriptions/:id");
    writeln("    GET    /api/v1/event-mesh/messages");
    writeln("    POST   /api/v1/event-mesh/messages");
    writeln("    GET    /api/v1/event-mesh/messages/:id");
    writeln("    PUT    /api/v1/event-mesh/messages/:id/acknowledge");
    writeln("    DELETE /api/v1/event-mesh/messages/:id");
    writeln("    GET    /api/v1/event-mesh/schemas");
    writeln("    POST   /api/v1/event-mesh/schemas");
    writeln("    GET    /api/v1/event-mesh/schemas/:id");
    writeln("    PUT    /api/v1/event-mesh/schemas/:id");
    writeln("    DELETE /api/v1/event-mesh/schemas/:id");
    writeln("    GET    /api/v1/event-mesh/applications");
    writeln("    POST   /api/v1/event-mesh/applications");
    writeln("    GET    /api/v1/event-mesh/applications/:id");
    writeln("    PUT    /api/v1/event-mesh/applications/:id");
    writeln("    DELETE /api/v1/event-mesh/applications/:id");
    writeln("    GET    /api/v1/event-mesh/bridges");
    writeln("    POST   /api/v1/event-mesh/bridges");
    writeln("    GET    /api/v1/event-mesh/bridges/:id");
    writeln("    PUT    /api/v1/event-mesh/bridges/:id");
    writeln("    DELETE /api/v1/event-mesh/bridges/:id");
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
