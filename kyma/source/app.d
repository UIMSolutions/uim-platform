/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.core.core : runApplication;

import uim.platform.kyma.infrastructure.config;
import uim.platform.kyma.infrastructure.container;

// import std.stdio : writefln;
@safe:

version (unittest)
{
}
else
{
  void main()
  {
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Register all controller routes (driving adapters)
    container.environmentController.registerRoutes(router);
    container.namespaceController.registerRoutes(router);
    container.functionController.registerRoutes(router);
    container.apiRuleController.registerRoutes(router);
    container.serviceInstanceController.registerRoutes(router);
    container.serviceBindingController.registerRoutes(router);
    container.eventSubscriptionController.registerRoutes(router);
    container.moduleController.registerRoutes(router);
    container.applicationController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];

    auto listener = listenHTTP(settings, router);

    writefln("==========================================================");
    writefln("  Kyma Runtime Service");
    writefln("  Listening on %s:%d", config.host, config.port);
    writefln("                                                          ");
    writefln("  Endpoints:                                              ");
    writefln("    CRUD      /api/v1/environments                        ");
    writefln("    CRUD      /api/v1/namespaces                          ");
    writefln("    CRUD      /api/v1/functions                           ");
    writefln("    CRUD      /api/v1/api-rules                           ");
    writefln("    CRUD      /api/v1/service-instances                   ");
    writefln("    CRUD      /api/v1/service-bindings                    ");
    writefln("    CRUD      /api/v1/event-subscriptions                 ");
    writefln("    POST      /api/v1/event-subscriptions/pause/{id}      ");
    writefln("    POST      /api/v1/event-subscriptions/resume/{id}     ");
    writefln("    CRUD      /api/v1/modules                             ");
    writefln("    POST      /api/v1/modules/disable/{id}                ");
    writefln("    CRUD      /api/v1/applications                        ");
    writefln("    POST      /api/v1/applications/connect/{id}           ");
    writefln("    POST      /api/v1/applications/disconnect/{id}        ");
    writefln("    GET       /api/v1/health                              ");
    writefln("==========================================================");

    runApplication();
  }
