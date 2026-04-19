/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.build_apps;

void main() {
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Register all controllers
    container.applicationController.registerRoutes(router);
    container.pageController.registerRoutes(router);
    container.uiComponentController.registerRoutes(router);
    container.dataEntityController.registerRoutes(router);
    container.dataConnectionController.registerRoutes(router);
    container.logicFlowController.registerRoutes(router);
    container.appBuildController.registerRoutes(router);
    container.projectMemberController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    writeln("====================================================");
    writeln("  Build Apps Service");
    writeln("====================================================");
    writeln("  Endpoints:");
    writeln("    GET    /api/v1/build-apps/applications");
    writeln("    POST   /api/v1/build-apps/applications");
    writeln("    GET    /api/v1/build-apps/applications/:id");
    writeln("    PUT    /api/v1/build-apps/applications/:id");
    writeln("    DELETE /api/v1/build-apps/applications/:id");
    writeln("    GET    /api/v1/build-apps/pages");
    writeln("    POST   /api/v1/build-apps/pages");
    writeln("    GET    /api/v1/build-apps/pages/:id");
    writeln("    PUT    /api/v1/build-apps/pages/:id");
    writeln("    DELETE /api/v1/build-apps/pages/:id");
    writeln("    GET    /api/v1/build-apps/ui-components");
    writeln("    POST   /api/v1/build-apps/ui-components");
    writeln("    GET    /api/v1/build-apps/ui-components/:id");
    writeln("    PUT    /api/v1/build-apps/ui-components/:id");
    writeln("    DELETE /api/v1/build-apps/ui-components/:id");
    writeln("    GET    /api/v1/build-apps/data-entities");
    writeln("    POST   /api/v1/build-apps/data-entities");
    writeln("    GET    /api/v1/build-apps/data-entities/:id");
    writeln("    PUT    /api/v1/build-apps/data-entities/:id");
    writeln("    DELETE /api/v1/build-apps/data-entities/:id");
    writeln("    GET    /api/v1/build-apps/data-connections");
    writeln("    POST   /api/v1/build-apps/data-connections");
    writeln("    GET    /api/v1/build-apps/data-connections/:id");
    writeln("    PUT    /api/v1/build-apps/data-connections/:id");
    writeln("    DELETE /api/v1/build-apps/data-connections/:id");
    writeln("    GET    /api/v1/build-apps/logic-flows");
    writeln("    POST   /api/v1/build-apps/logic-flows");
    writeln("    GET    /api/v1/build-apps/logic-flows/:id");
    writeln("    PUT    /api/v1/build-apps/logic-flows/:id");
    writeln("    DELETE /api/v1/build-apps/logic-flows/:id");
    writeln("    GET    /api/v1/build-apps/app-builds");
    writeln("    POST   /api/v1/build-apps/app-builds");
    writeln("    GET    /api/v1/build-apps/app-builds/:id");
    writeln("    PUT    /api/v1/build-apps/app-builds/:id");
    writeln("    DELETE /api/v1/build-apps/app-builds/:id");
    writeln("    GET    /api/v1/build-apps/project-members");
    writeln("    POST   /api/v1/build-apps/project-members");
    writeln("    GET    /api/v1/build-apps/project-members/:id");
    writeln("    PUT    /api/v1/build-apps/project-members/:id");
    writeln("    DELETE /api/v1/build-apps/project-members/:id");
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
