module app;

import vibe.http.server;
import vibe.http.router;
import vibe.core.core : runApplication;

import infrastructure.config;
import infrastructure.container;

import std.stdio : writefln;

void main()
{
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Register all controller routes (driving adapters)
    container.workspaceController.registerRoutes(router);
    container.workpageController.registerRoutes(router);
    container.cardController.registerRoutes(router);
    container.contentController.registerRoutes(router);
    container.feedController.registerRoutes(router);
    container.notificationController.registerRoutes(router);
    container.taskController.registerRoutes(router);
    container.channelController.registerRoutes(router);
    container.appController.registerRoutes(router);
    container.widgetController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];

    auto listener = listenHTTP(settings, router);

    writefln("==========================================================");
    writefln("  Workzone Service");
    writefln("  Listening on %s:%d", config.host, config.port);
    writefln("                                                          ");
    writefln("  Endpoints:                                              ");
    writefln("    CRUD /api/v1/workspaces                               ");
    writefln("    CRUD /api/v1/workpages                                ");
    writefln("    CRUD /api/v1/cards                                    ");
    writefln("    CRUD /api/v1/content                                  ");
    writefln("    CRUD /api/v1/feeds                                    ");
    writefln("    CRUD /api/v1/notifications                            ");
    writefln("    CRUD /api/v1/tasks                                    ");
    writefln("    CRUD /api/v1/channels                                 ");
    writefln("    CRUD /api/v1/apps                                     ");
    writefln("    CRUD /api/v1/widgets                                  ");
    writefln("     GET /api/v1/health                                   ");
    writefln("==========================================================");

    runApplication();
}
