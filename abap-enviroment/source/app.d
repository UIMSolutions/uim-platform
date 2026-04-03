module app;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.core.core : runApplication;

import uim.platform.abap_enviroment.infrastructure.config;
import uim.platform.abap_enviroment.infrastructure.container;

// import std.stdio : writefln;

void main() {
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Register all controller routes (driving adapters)
    container.systemInstanceController.registerRoutes(router);
    container.softwareComponentController.registerRoutes(router);
    container.communicationArrangementController.registerRoutes(router);
    container.serviceBindingController.registerRoutes(router);
    container.businessUserController.registerRoutes(router);
    container.businessRoleController.registerRoutes(router);
    container.transportRequestController.registerRoutes(router);
    container.applicationJobController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];

    auto listener = listenHTTP(settings, router);

    writefln("==========================================================");
    writefln("  ABAP Environment Service");
    writefln("  Listening on %s:%d", config.host, config.port);
    writefln("                                                          ");
    writefln("  Endpoints:                                              ");
    writefln("    CRUD      /api/v1/systems                             ");
    writefln("    CRUD+     /api/v1/software-components                 ");
    writefln("    CRUD      /api/v1/communication-arrangements          ");
    writefln("    CRUD      /api/v1/service-bindings                    ");
    writefln("    CRUD      /api/v1/business-users                      ");
    writefln("    CRUD      /api/v1/business-roles                      ");
    writefln("    CRUD+     /api/v1/transports                          ");
    writefln("    CRUD+     /api/v1/application-jobs                    ");
    writefln("    GET       /api/v1/health                              ");
    writefln("==========================================================");

    runApplication();
}
