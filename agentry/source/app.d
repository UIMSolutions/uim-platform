/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.agentry;

@safe:
version (unittest) {
}
else {
  void main() {
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Register all controllers
    container.mobileApplicationController.registerRoutes(router);
    container.appDefinitionController.registerRoutes(router);
    container.appVersionController.registerRoutes(router);
    container.deviceController.registerRoutes(router);
    container.syncSessionController.registerRoutes(router);
    container.backendConnectionController.registerRoutes(router);
    container.deploymentController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    writeln("====================================================");
    writeln("  UIM Agentry Platform Service");
    writeln("====================================================");
    writeln("  Metadata-driven mobile application platform");
    writeln("  Port: ", config.port);
    writeln("----------------------------------------------------");
    writeln("  Endpoints:");
    writeln("    GET    /api/v1/health");
    writeln("    GET    /api/v1/agentry/mobile-applications");
    writeln("    POST   /api/v1/agentry/mobile-applications");
    writeln("    GET    /api/v1/agentry/mobile-applications/:id");
    writeln("    PUT    /api/v1/agentry/mobile-applications/:id");
    writeln("    DELETE /api/v1/agentry/mobile-applications/:id");
    writeln("    GET    /api/v1/agentry/app-definitions");
    writeln("    POST   /api/v1/agentry/app-definitions");
    writeln("    GET    /api/v1/agentry/app-definitions/:id");
    writeln("    PUT    /api/v1/agentry/app-definitions/:id");
    writeln("    DELETE /api/v1/agentry/app-definitions/:id");
    writeln("    GET    /api/v1/agentry/app-versions");
    writeln("    POST   /api/v1/agentry/app-versions");
    writeln("    GET    /api/v1/agentry/app-versions/:id");
    writeln("    PUT    /api/v1/agentry/app-versions/:id");
    writeln("    DELETE /api/v1/agentry/app-versions/:id");
    writeln("    GET    /api/v1/agentry/devices");
    writeln("    POST   /api/v1/agentry/devices");
    writeln("    GET    /api/v1/agentry/devices/:id");
    writeln("    PUT    /api/v1/agentry/devices/:id");
    writeln("    DELETE /api/v1/agentry/devices/:id");
    writeln("    GET    /api/v1/agentry/sync-sessions");
    writeln("    POST   /api/v1/agentry/sync-sessions");
    writeln("    GET    /api/v1/agentry/sync-sessions/:id");
    writeln("    PUT    /api/v1/agentry/sync-sessions/:id");
    writeln("    DELETE /api/v1/agentry/sync-sessions/:id");
    writeln("    GET    /api/v1/agentry/backend-connections");
    writeln("    POST   /api/v1/agentry/backend-connections");
    writeln("    GET    /api/v1/agentry/backend-connections/:id");
    writeln("    PUT    /api/v1/agentry/backend-connections/:id");
    writeln("    DELETE /api/v1/agentry/backend-connections/:id");
    writeln("    GET    /api/v1/agentry/deployments");
    writeln("    POST   /api/v1/agentry/deployments");
    writeln("    GET    /api/v1/agentry/deployments/:id");
    writeln("    PUT    /api/v1/agentry/deployments/:id");
    writeln("    DELETE /api/v1/agentry/deployments/:id");
    writeln("====================================================");

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];
    auto listener = listenHTTP(settings, router);
    scope (exit) listener.stopListening();
    runApplication();
  }
}
