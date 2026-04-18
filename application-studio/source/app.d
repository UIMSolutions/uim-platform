/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.application_studio;

void main() {
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Register all controllers
    container.devSpaceController.registerRoutes(router);
    container.devSpaceTypeController.registerRoutes(router);
    container.extensionController.registerRoutes(router);
    container.projectController.registerRoutes(router);
    container.projectTemplateController.registerRoutes(router);
    container.serviceBindingController.registerRoutes(router);
    container.runConfigurationController.registerRoutes(router);
    container.buildConfigurationController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    writeln("====================================================");
    writeln("  Application Studio Service");
    writeln("====================================================");
    writeln("  Endpoints:");
    writeln("    GET    /api/v1/application-studio/dev-spaces");
    writeln("    POST   /api/v1/application-studio/dev-spaces");
    writeln("    GET    /api/v1/application-studio/dev-spaces/:id");
    writeln("    PUT    /api/v1/application-studio/dev-spaces/:id");
    writeln("    DELETE /api/v1/application-studio/dev-spaces/:id");
    writeln("    GET    /api/v1/application-studio/dev-space-types");
    writeln("    POST   /api/v1/application-studio/dev-space-types");
    writeln("    GET    /api/v1/application-studio/dev-space-types/:id");
    writeln("    PUT    /api/v1/application-studio/dev-space-types/:id");
    writeln("    DELETE /api/v1/application-studio/dev-space-types/:id");
    writeln("    GET    /api/v1/application-studio/extensions");
    writeln("    POST   /api/v1/application-studio/extensions");
    writeln("    GET    /api/v1/application-studio/extensions/:id");
    writeln("    PUT    /api/v1/application-studio/extensions/:id");
    writeln("    DELETE /api/v1/application-studio/extensions/:id");
    writeln("    GET    /api/v1/application-studio/projects");
    writeln("    POST   /api/v1/application-studio/projects");
    writeln("    GET    /api/v1/application-studio/projects/:id");
    writeln("    PUT    /api/v1/application-studio/projects/:id");
    writeln("    DELETE /api/v1/application-studio/projects/:id");
    writeln("    GET    /api/v1/application-studio/project-templates");
    writeln("    POST   /api/v1/application-studio/project-templates");
    writeln("    GET    /api/v1/application-studio/project-templates/:id");
    writeln("    PUT    /api/v1/application-studio/project-templates/:id");
    writeln("    DELETE /api/v1/application-studio/project-templates/:id");
    writeln("    GET    /api/v1/application-studio/service-bindings");
    writeln("    POST   /api/v1/application-studio/service-bindings");
    writeln("    GET    /api/v1/application-studio/service-bindings/:id");
    writeln("    PUT    /api/v1/application-studio/service-bindings/:id");
    writeln("    DELETE /api/v1/application-studio/service-bindings/:id");
    writeln("    GET    /api/v1/application-studio/run-configurations");
    writeln("    POST   /api/v1/application-studio/run-configurations");
    writeln("    GET    /api/v1/application-studio/run-configurations/:id");
    writeln("    PUT    /api/v1/application-studio/run-configurations/:id");
    writeln("    DELETE /api/v1/application-studio/run-configurations/:id");
    writeln("    GET    /api/v1/application-studio/build-configurations");
    writeln("    POST   /api/v1/application-studio/build-configurations");
    writeln("    GET    /api/v1/application-studio/build-configurations/:id");
    writeln("    PUT    /api/v1/application-studio/build-configurations/:id");
    writeln("    DELETE /api/v1/application-studio/build-configurations/:id");
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
