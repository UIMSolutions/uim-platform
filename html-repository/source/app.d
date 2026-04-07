/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.html_repository.infrastructure.config;
import uim.platform.html_repository.infrastructure.container;

@safe:

version (unittest) {
} ) {
  void main() {
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Register all controller routes (driving adapters)
    container.htmlAppController.registerRoutes(router);
    container.appVersionController.registerRoutes(router);
    container.appFileController.registerRoutes(router);
    container.serviceInstanceController.registerRoutes(router);
    container.deploymentController.registerRoutes(router);
    container.appRouteController.registerRoutes(router);
    container.contentCacheController.registerRoutes(router);
    container.contentController.registerRoutes(router);
    container.overviewController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];

    auto listener = listenHTTP(settings, router);

    writefln("==========================================================");
    writefln("  HTML5 Application Repository Service");
    writefln("  Listening on %s:%d", config.host, config.port);
    writefln("                                                          ");
    writefln("  Endpoints:                                              ");
    writefln("    CRUD      /api/v1/apps                                ");
    writefln("    CRUD      /api/v1/versions                            ");
    writefln("    CRUD      /api/v1/files                               ");
    writefln("    CRUD      /api/v1/instances                           ");
    writefln("    POST/GET  /api/v1/deployments                         ");
    writefln("    CRUD      /api/v1/routes                              ");
    writefln("    CRUD      /api/v1/cache                               ");
    writefln("    POST      /api/v1/cache/purge                         ");
    writefln("    GET       /api/v1/content/*                           ");
    writefln("    GET       /api/v1/overview                            ");
    writefln("    GET       /api/v1/health                              ");
    writefln("==========================================================");

    runApplication();
  }
}
