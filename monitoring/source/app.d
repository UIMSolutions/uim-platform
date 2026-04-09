/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.core.core : runApplication;

// import uim.platform.monitoring.infrastructure.config;
// import uim.platform.monitoring.infrastructure.container;

// import std.stdio : writefln;
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:

version (unittest) {
}
else {
  void main() {
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Register all controller routes (driving adapters)
    container.resourceController.registerRoutes(router);
    container.metricController.registerRoutes(router);
    container.metricDefinitionController.registerRoutes(router);
    container.checkController.registerRoutes(router);
    container.alertRuleController.registerRoutes(router);
    container.alertController.registerRoutes(router);
    container.channelController.registerRoutes(router);
    container.dashboardController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];

    auto listener = listenHTTP(settings, router);

    writefln("==========================================================");
    writefln("  Monitoring Service");
    writefln("  Listening on %s:%d", config.host, config.port);
    writefln("                                                          ");
    writefln("  Endpoints:                                              ");
    writefln("    CRUD      /api/v1/resources                           ");
    writefln("    POST/GET  /api/v1/metrics                             ");
    writefln("    POST      /api/v1/metrics/batch                       ");
    writefln("    GET       /api/v1/metrics/summary                     ");
    writefln("    CRUD      /api/v1/metric-definitions                  ");
    writefln("    CRUD      /api/v1/checks                              ");
    writefln("    POST      /api/v1/checks/results                      ");
    writefln("    GET       /api/v1/checks/results/{checkId}            ");
    writefln("    CRUD      /api/v1/alert-rules                         ");
    writefln("    GET       /api/v1/alerts                              ");
    writefln("    POST      /api/v1/alerts/acknowledge                  ");
    writefln("    POST      /api/v1/alerts/resolve                      ");
    writefln("    CRUD      /api/v1/channels                            ");
    writefln("    GET       /api/v1/dashboard                           ");
    writefln("    GET       /api/v1/health                              ");
    writefln("==========================================================");

    runApplication();
  }
}