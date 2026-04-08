/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.core.core : runApplication;

import uim.platform.data.quality.infrastructure.config;
import uim.platform.data.quality.infrastructure.container;

// import std.stdio : writefln;
@safe:

version (unittest) {
} else {
  void main() {
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Register all controller routes (driving adapters)
    container.validationRuleController.registerRoutes(router);
    container.validateController.registerRoutes(router);
    container.addressController.registerRoutes(router);
    container.duplicateController.registerRoutes(router);
    container.profileController.registerRoutes(router);
    container.cleansingRuleController.registerRoutes(router);
    container.cleansingJobController.registerRoutes(router);
    container.dashboardController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];

    auto listener = listenHTTP(settings, router);

    writefln("==========================================================");
    writefln("  Data Quality Management Service");
    writefln("  Listening on %s:%d", config.host, config.port);
    writefln("                                                          ");
    writefln("  Endpoints:                                              ");
    writefln("    CRUD      /api/v1/validation-rules                    ");
    writefln("    POST      /api/v1/validate                            ");
    writefln("    POST      /api/v1/validate/batch                      ");
    writefln("    POST/GET  /api/v1/addresses/cleanse                   ");
    writefln("    POST      /api/v1/addresses/cleanse/batch             ");
    writefln("    POST/GET  /api/v1/duplicates                          ");
    writefln("    POST      /api/v1/duplicates/detect                   ");
    writefln("    POST      /api/v1/duplicates/resolve                  ");
    writefln("    POST/GET  /api/v1/profiles                            ");
    writefln("    CRUD      /api/v1/cleansing-rules                     ");
    writefln("    POST/GET  /api/v1/cleansing-jobs                      ");
    writefln("    POST      /api/v1/dashboard                           ");
    writefln("    GET       /api/v1/health                              ");
    writefln("==========================================================");

    runApplication();
  }
}
