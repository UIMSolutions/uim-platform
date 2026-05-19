/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.integration_delivery;

@safe:

version (unittest) {
}
else {
    void main() {
        auto config = loadConfig();
        auto container = buildContainer(config);

        auto router = new URLRouter();

        // Register all controllers
        container.cicdRepositoryController.registerRoutes(router);
        container.credentialController.registerRoutes(router);
        container.pipelineController.registerRoutes(router);
        container.jobController.registerRoutes(router);
        container.buildController.registerRoutes(router);
        container.stageController.registerRoutes(router);
        container.webhookController.registerRoutes(router);
        container.deploymentTargetController.registerRoutes(router);
        container.healthController.registerRoutes(router);

        writeln("====================================================");
        writeln("  SAP Continuous Integration and Delivery Service");
        writeln("====================================================");
        writeln("  Endpoints:");
        writeln("    GET    /api/v1/integration-delivery/repositories");
        writeln("    POST   /api/v1/integration-delivery/repositories");
        writeln("    GET    /api/v1/integration-delivery/repositories/:id");
        writeln("    PUT    /api/v1/integration-delivery/repositories/:id");
        writeln("    DELETE /api/v1/integration-delivery/repositories/:id");
        writeln("    GET    /api/v1/integration-delivery/credentials");
        writeln("    POST   /api/v1/integration-delivery/credentials");
        writeln("    GET    /api/v1/integration-delivery/credentials/:id");
        writeln("    PUT    /api/v1/integration-delivery/credentials/:id");
        writeln("    DELETE /api/v1/integration-delivery/credentials/:id");
        writeln("    GET    /api/v1/integration-delivery/pipelines");
        writeln("    POST   /api/v1/integration-delivery/pipelines");
        writeln("    GET    /api/v1/integration-delivery/pipelines/:id");
        writeln("    PUT    /api/v1/integration-delivery/pipelines/:id");
        writeln("    DELETE /api/v1/integration-delivery/pipelines/:id");
        writeln("    GET    /api/v1/integration-delivery/jobs");
        writeln("    POST   /api/v1/integration-delivery/jobs");
        writeln("    GET    /api/v1/integration-delivery/jobs/:id");
        writeln("    PUT    /api/v1/integration-delivery/jobs/:id");
        writeln("    DELETE /api/v1/integration-delivery/jobs/:id");
        writeln("    GET    /api/v1/integration-delivery/builds");
        writeln("    POST   /api/v1/integration-delivery/builds");
        writeln("    GET    /api/v1/integration-delivery/builds/:id");
        writeln("    PUT    /api/v1/integration-delivery/builds/:id");
        writeln("    DELETE /api/v1/integration-delivery/builds/:id");
        writeln("    GET    /api/v1/integration-delivery/stages");
        writeln("    POST   /api/v1/integration-delivery/stages");
        writeln("    GET    /api/v1/integration-delivery/stages/:id");
        writeln("    PUT    /api/v1/integration-delivery/stages/:id");
        writeln("    DELETE /api/v1/integration-delivery/stages/:id");
        writeln("    GET    /api/v1/integration-delivery/webhooks");
        writeln("    POST   /api/v1/integration-delivery/webhooks");
        writeln("    GET    /api/v1/integration-delivery/webhooks/:id");
        writeln("    PUT    /api/v1/integration-delivery/webhooks/:id");
        writeln("    DELETE /api/v1/integration-delivery/webhooks/:id");
        writeln("    GET    /api/v1/integration-delivery/deployment-targets");
        writeln("    POST   /api/v1/integration-delivery/deployment-targets");
        writeln("    GET    /api/v1/integration-delivery/deployment-targets/:id");
        writeln("    PUT    /api/v1/integration-delivery/deployment-targets/:id");
        writeln("    DELETE /api/v1/integration-delivery/deployment-targets/:id");
        writeln("    GET    /health");
        writeln("====================================================");
        writeln("  Listening on ", config.host, ":", config.port);
        writeln("====================================================");

        auto settings = new HTTPServerSettings();
        settings.port = config.port;
        settings.bindAddresses = [config.host];

        listenHTTP(settings, router);
        runApplication();
    }
}
