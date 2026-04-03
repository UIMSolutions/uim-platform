/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.logging.infrastructure.config;
import uim.platform.logging.infrastructure.container;

@safe:

version (unittest) {
} else {
  void main() {
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Register all controller routes (driving adapters)
    container.logController.registerRoutes(router);
    container.traceController.registerRoutes(router);
    container.searchController.registerRoutes(router);
    container.streamController.registerRoutes(router);
    container.dashboardController.registerRoutes(router);
    container.retentionController.registerRoutes(router);
    container.alertRuleController.registerRoutes(router);
    container.alertController.registerRoutes(router);
    container.channelController.registerRoutes(router);
    container.pipelineController.registerRoutes(router);
    container.overviewController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];

    auto listener = listenHTTP(settings, router);

    writefln("==========================================================");
    writefln("  Cloud Logging Service");
    writefln("  Listening on %s:%d", config.host, config.port);
    writefln("                                                          ");
    writefln("  Endpoints:                                              ");
    writefln("    POST      /api/v1/logs                                ");
    writefln("    POST      /api/v1/logs/batch                          ");
    writefln("    POST      /api/v1/traces/spans                        ");
    writefln("    POST      /api/v1/traces/spans/batch                  ");
    writefln("    GET       /api/v1/traces/{traceId}                    ");
    writefln("    GET       /api/v1/search?q=...                        ");
    writefln("    GET       /api/v1/logs/{id}                           ");
    writefln("    CRUD      /api/v1/streams                             ");
    writefln("    CRUD      /api/v1/dashboards                          ");
    writefln("    CRUD      /api/v1/retention                           ");
    writefln("    CRUD      /api/v1/alert-rules                         ");
    writefln("    GET       /api/v1/alerts                              ");
    writefln("    POST      /api/v1/alerts/acknowledge                  ");
    writefln("    POST      /api/v1/alerts/resolve                      ");
    writefln("    CRUD      /api/v1/channels                            ");
    writefln("    CRUD      /api/v1/pipelines                           ");
    writefln("    GET       /api/v1/overview                            ");
    writefln("    GET       /api/v1/health                              ");
    writefln("==========================================================");

    runApplication();
  }
}
