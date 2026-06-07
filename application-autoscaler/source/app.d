/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.application_autoscaler;

// mixin(ShowModule!());

@safe:

version (unittest) {
} else {
  void main() {
    auto config    = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Register all controller routes (driving adapters)
    container.policyController.registerRoutes(router);
    container.bindingController.registerRoutes(router);
    container.customMetricController.registerRoutes(router);
    container.scalingEngineController.registerRoutes(router);
    container.historyController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    auto settings          = new HTTPServerSettings();
    settings.port          = config.port;
    settings.bindAddresses = [config.host];

    listenHTTP(settings, router);

    writefln("=================================================================");
    writefln("  Application Autoscaler Service (SAP BTP-compatible)           ");
    writefln("  Listening on %s:%d", config.host, config.port);
    writefln("                                                                 ");
    writefln("  Endpoints:                                                     ");
    writefln("    POST/GET/PUT/DELETE  /api/v1/policies                       ");
    writefln("    POST/GET/DELETE      /api/v1/bindings                       ");
    writefln("    POST                 /api/v1/bindings/{id}/policy           ");
    writefln("    POST/GET             /api/v1/apps/{id}/metrics              ");
    writefln("    POST                 /api/v1/scaling/trigger                ");
    writefln("    GET                  /api/v1/apps/{id}/scaling-history      ");
    writefln("    GET                  /api/v1/scaling-history/{id}           ");
    writefln("    GET                  /api/v1/health                         ");
    writefln("=================================================================");

    runApplication();
  }
}
