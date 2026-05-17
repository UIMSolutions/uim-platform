/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.events;

version (unittest) {
}
else {
    void main() {
        auto config = loadConfig();
        auto container = buildContainer(config);

        auto router = new URLRouter();

        container.messagingServiceController.registerRoutes(router);
        container.messageClientController.registerRoutes(router);
        container.queueController.registerRoutes(router);
        container.queueSubscriptionController.registerRoutes(router);
        container.webhookController.registerRoutes(router);
        container.eventChannelController.registerRoutes(router);
        container.messageBindingController.registerRoutes(router);
        container.healthController.registerRoutes(router);

        writeln("====================================================");
        writeln("  SAP Event Mesh Service");
        writeln("====================================================");
        writeln("  Endpoints:");
        writeln("    GET    /api/v1/sap-event-mesh/messaging-services");
        writeln("    POST   /api/v1/sap-event-mesh/messaging-services");
        writeln("    GET    /api/v1/sap-event-mesh/messaging-services/:id");
        writeln("    PUT    /api/v1/sap-event-mesh/messaging-services/:id");
        writeln("    DELETE /api/v1/sap-event-mesh/messaging-services/:id");
        writeln("    GET    /api/v1/sap-event-mesh/message-clients");
        writeln("    POST   /api/v1/sap-event-mesh/message-clients");
        writeln("    GET    /api/v1/sap-event-mesh/message-clients/:id");
        writeln("    PUT    /api/v1/sap-event-mesh/message-clients/:id");
        writeln("    DELETE /api/v1/sap-event-mesh/message-clients/:id");
        writeln("    GET    /api/v1/sap-event-mesh/queues");
        writeln("    POST   /api/v1/sap-event-mesh/queues");
        writeln("    GET    /api/v1/sap-event-mesh/queues/:id");
        writeln("    PUT    /api/v1/sap-event-mesh/queues/:id");
        writeln("    DELETE /api/v1/sap-event-mesh/queues/:id");
        writeln("    GET    /api/v1/sap-event-mesh/queue-subscriptions");
        writeln("    POST   /api/v1/sap-event-mesh/queue-subscriptions");
        writeln("    GET    /api/v1/sap-event-mesh/queue-subscriptions/:id");
        writeln("    PUT    /api/v1/sap-event-mesh/queue-subscriptions/:id");
        writeln("    DELETE /api/v1/sap-event-mesh/queue-subscriptions/:id");
        writeln("    GET    /api/v1/sap-event-mesh/webhooks");
        writeln("    POST   /api/v1/sap-event-mesh/webhooks");
        writeln("    GET    /api/v1/sap-event-mesh/webhooks/:id");
        writeln("    PUT    /api/v1/sap-event-mesh/webhooks/:id");
        writeln("    DELETE /api/v1/sap-event-mesh/webhooks/:id");
        writeln("    GET    /api/v1/sap-event-mesh/event-channels");
        writeln("    POST   /api/v1/sap-event-mesh/event-channels");
        writeln("    GET    /api/v1/sap-event-mesh/event-channels/:id");
        writeln("    PUT    /api/v1/sap-event-mesh/event-channels/:id");
        writeln("    DELETE /api/v1/sap-event-mesh/event-channels/:id");
        writeln("    GET    /api/v1/sap-event-mesh/message-bindings");
        writeln("    POST   /api/v1/sap-event-mesh/message-bindings");
        writeln("    GET    /api/v1/sap-event-mesh/message-bindings/:id");
        writeln("    PUT    /api/v1/sap-event-mesh/message-bindings/:id");
        writeln("    DELETE /api/v1/sap-event-mesh/message-bindings/:id");
        writeln("    GET    /api/v1/health");
        writeln("====================================================");
        writefln("  Listening on %s:%d", config.host, config.port);
        writeln("====================================================");

        auto settings = new HTTPServerSettings();
        settings.port = config.port;
        settings.bindAddresses = [config.host];

        listenHTTP(settings, router);
        runApplication();
    }
}
