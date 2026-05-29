/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.market_refinitiv;

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
    container.webView.registerRoutes(router);

    auto settings = new HTTPServerSettings();
    settings.port         = config.port;
    settings.bindAddresses = [config.host];

    auto listener = listenHTTP(settings, router);

    writefln("==========================================================");
    writefln("  Market Rates Management - Refinitiv Data Option         ");
    writefln("  Listening on %s:%d", config.host, config.port);
    writefln("  Storage backend: %s", config.storageBackend);
    writefln("                                                          ");
    writefln("  API v1 Endpoints:                                      ");
    writefln("    POST      /api/v1/market_refinitiv/upload            ");
    writefln("    POST      /api/v1/market_refinitiv/download          ");
    writefln("    GET       /api/v1/market_refinitiv/rates             ");
    writefln("    GET       /api/v1/market_refinitiv/rates/:id         ");
    writefln("    DELETE    /api/v1/market_refinitiv/rates             ");
    writefln("    GET       /api/v1/market_refinitiv/providers         ");
    writefln("    POST      /api/v1/market_refinitiv/providers         ");
    writefln("    GET       /api/v1/market_refinitiv/providers/:id     ");
    writefln("    PUT       /api/v1/market_refinitiv/providers/:id     ");
    writefln("    DELETE    /api/v1/market_refinitiv/providers/:id     ");
    writefln("    GET       /api/v1/market_refinitiv/auditlogs         ");
    writefln("    GET       /web/market-refinitiv                      ");
    writefln("                                                          ");
    writefln("  Health:                                                 ");
    writefln("    GET       /api/v1/health                              ");
    writefln("==========================================================");

    runApplication();
  }
}
