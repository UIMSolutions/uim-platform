/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.core.core : runApplication;

// import uim.platform.portal.infrastructure.config;
// import uim.platform.portal.infrastructure.container;

// import std.stdio : writefln;
import uim.platform.portal;


version (unittest)
{
}
else
{
  void main()
  {
    // Load configuration
    auto config = loadConfig();

    // Build dependency injection container (hexagonal wiring)
    auto container = buildContainer(config);

    // Configure vibe.d HTTP server
    auto router = new URLRouter();

    // Register all controller routes (driving adapters)
    container.siteController.registerRoutes(router);
    container.pageController.registerRoutes(router);
    container.sectionController.registerRoutes(router);
    container.tileController.registerRoutes(router);
    container.catalogController.registerRoutes(router);
    container.providerController.registerRoutes(router);
    container.roleController.registerRoutes(router);
    container.themeController.registerRoutes(router);
    container.menuItemController.registerRoutes(router);
    container.translationController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];

    auto listener = listenHTTP(settings, router);

    writefln("╔══════════════════════════════════════════════════════╗");
    writefln("║  Cloud Portal Service                                ║");
    writefln("║  Listening on %s:%d                            ║", config.host, config.port);
    writefln("║                                                      ║");
    writefln("║  Portal Endpoints:                                   ║");
    writefln("║    CRUD /api/v1/sites                                ║");
    writefln("║    CRUD /api/v1/pages                                ║");
    writefln("║    CRUD /api/v1/sections                             ║");
    writefln("║    CRUD /api/v1/tiles                                ║");
    writefln("║    CRUD /api/v1/catalogs                             ║");
    writefln("║    CRUD /api/v1/providers                            ║");
    writefln("║    CRUD /api/v1/roles                                ║");
    writefln("║    CRUD /api/v1/themes                               ║");
    writefln("║    CRUD /api/v1/menu-items                           ║");
    writefln("║    CRUD /api/v1/translations                         ║");
    writefln("║     GET /api/v1/health                               ║");
    writefln("╚══════════════════════════════════════════════════════╝");

    runApplication();
  }
}