/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.marketrates;

mixin(ShowModule!());

@safe:
version (unittest) {
} else {
  void main() {
    auto config    = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Driving adapters – register all controller routes
    container.marketRateController.registerRoutes(router);
    container.auditLogController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    auto settings = new HTTPServerSettings();
    settings.port         = config.port;
    settings.bindAddresses = [config.host];

    auto listener = listenHTTP(settings, router);

    writefln("==========================================================");
    writefln("  Market Rates Management - Bring Your Own Rates          ");
    writefln("  Listening on %s:%d", config.host, config.port);
    writefln("                                                          ");
    writefln("  Market Rates API v1 Endpoints:                          ");
    writefln("    POST      /api/v1/marketrates/upload                  ");
    writefln("    POST      /api/v1/marketrates/download                ");
    writefln("    GET       /api/v1/marketrates/rates                   ");
    writefln("    GET       /api/v1/marketrates/rates/:id               ");
    writefln("    DELETE    /api/v1/marketrates/rates/:id               ");
    writefln("    GET       /api/v1/marketrates/providers               ");
    writefln("    POST      /api/v1/marketrates/providers               ");
    writefln("    GET       /api/v1/marketrates/providers/:id           ");
    writefln("    PUT       /api/v1/marketrates/providers/:id           ");
    writefln("    DELETE    /api/v1/marketrates/providers/:id           ");
    writefln("    GET       /api/v1/marketrates/auditlogs               ");
    writefln("                                                          ");
    writefln("  Health:                                                 ");
    writefln("    GET       /api/v1/health                              ");
    writefln("==========================================================");

    runApplication();
  }
}
