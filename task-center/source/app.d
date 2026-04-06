/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.task_center;

void main() {
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Register all controllers
    container.taskController.registerRoutes(router);
    container.definitionController.registerRoutes(router);
    container.commentController.registerRoutes(router);
    container.attachmentController.registerRoutes(router);
    container.providerController.registerRoutes(router);
    container.substitutionController.registerRoutes(router);
    container.actionController.registerRoutes(router);
    container.filterController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    writeln("====================================================");
    writeln("  Task Center Service");
    writeln("====================================================");
    writeln("  Endpoints:");
    writeln("    GET  /api/v1/task-center/tasks");
    writeln("    POST /api/v1/task-center/tasks");
    writeln("    GET  /api/v1/task-center/tasks/:id");
    writeln("    PUT  /api/v1/task-center/tasks/:id");
    writeln("    POST /api/v1/task-center/tasks/:id/claim");
    writeln("    POST /api/v1/task-center/tasks/:id/release");
    writeln("    POST /api/v1/task-center/tasks/:id/forward");
    writeln("    POST /api/v1/task-center/tasks/:id/complete");
    writeln("    POST /api/v1/task-center/tasks/:id/cancel");
    writeln("    GET  /api/v1/task-center/definitions");
    writeln("    POST /api/v1/task-center/definitions");
    writeln("    POST /api/v1/task-center/definitions/:id/activate");
    writeln("    POST /api/v1/task-center/definitions/:id/deactivate");
    writeln("    GET  /api/v1/task-center/providers");
    writeln("    POST /api/v1/task-center/providers");
    writeln("    POST /api/v1/task-center/providers/:id/activate");
    writeln("    POST /api/v1/task-center/providers/:id/sync");
    writeln("    GET  /api/v1/task-center/comments");
    writeln("    POST /api/v1/task-center/comments");
    writeln("    GET  /api/v1/task-center/attachments");
    writeln("    POST /api/v1/task-center/attachments");
    writeln("    GET  /api/v1/task-center/substitutions");
    writeln("    POST /api/v1/task-center/substitutions");
    writeln("    POST /api/v1/task-center/substitutions/:id/activate");
    writeln("    GET  /api/v1/task-center/actions");
    writeln("    POST /api/v1/task-center/actions");
    writeln("    GET  /api/v1/task-center/filters");
    writeln("    POST /api/v1/task-center/filters");
    writeln("    POST /api/v1/task-center/filters/:id/default");
    writeln("    GET  /health");
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
