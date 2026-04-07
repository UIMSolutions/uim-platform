/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.mobile.infrastructure.config;
import uim.platform.mobile.infrastructure.container;

@safe:

version (unittest) {
} else {
  void main() {
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Register all controller routes (driving adapters)
    container.mobileAppController.registerRoutes(router);
    container.deviceRegistrationController.registerRoutes(router);
    container.pushNotificationController.registerRoutes(router);
    container.pushRegistrationController.registerRoutes(router);
    container.appConfigurationController.registerRoutes(router);
    container.featureRestrictionController.registerRoutes(router);
    container.clientResourceController.registerRoutes(router);
    container.appVersionController.registerRoutes(router);
    container.usageReportController.registerRoutes(router);
    container.offlineStoreController.registerRoutes(router);
    container.userSessionController.registerRoutes(router);
    container.clientLogController.registerRoutes(router);
    container.overviewController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];

    auto listener = listenHTTP(settings, router);

    writefln("==========================================================");
    writefln("  Mobile Services");
    writefln("  Listening on %s:%d", config.host, config.port);
    writefln("                                                          ");
    writefln("  Endpoints:                                              ");
    writefln("    CRUD      /api/v1/apps                                ");
    writefln("    CRUD      /api/v1/devices                             ");
    writefln("    CRUD      /api/v1/push/notifications                  ");
    writefln("    CRUD      /api/v1/push/registrations                  ");
    writefln("    CRUD      /api/v1/configurations                      ");
    writefln("    CRUD      /api/v1/features                            ");
    writefln("    POST      /api/v1/features/evaluate                   ");
    writefln("    CRUD      /api/v1/resources                           ");
    writefln("    CRUD      /api/v1/versions                            ");
    writefln("    POST/GET  /api/v1/usage                               ");
    writefln("    CRUD      /api/v1/offline-stores                      ");
    writefln("    CRUD      /api/v1/sessions                            ");
    writefln("    POST/GET  /api/v1/logs                                ");
    writefln("    GET       /api/v1/overview                            ");
    writefln("    GET       /api/v1/health                              ");
    writefln("==========================================================");

    runApplication();
  }
}
