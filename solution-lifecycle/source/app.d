/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.solution_lifecycle;

mixin(ShowModule!());

@safe:

version (unittest) {
} else {
    void main() {
        auto config = loadConfig();
        auto container = buildContainer(config);

        auto router = new URLRouter();

        // Register all controller routes (driving adapters)
        container.mtaArchiveController.registerRoutes(router);
        container.mtaController.registerRoutes(router);
        container.mtaOperationController.registerRoutes(router);
        container.mtaSubscriptionController.registerRoutes(router);
        container.healthController.registerRoutes(router);

        auto settings = new HTTPServerSettings();
        settings.port = config.port;
        settings.bindAddresses = [config.host];

        auto listener = listenHTTP(settings, router);

        writefln("==========================================================");
        writefln("  Solution Lifecycle Management Service");
        writefln("  Listening on %s:%d", config.host, config.port);
        writefln("                                                          ");
        writefln("  SLM API v1 Endpoints:                                  ");
        writefln("    GET/POST/DELETE  /api/v1/slm/mta-archives             ");
        writefln("    GET              /api/v1/slm/mta-archives/*           ");
        writefln("    GET/POST         /api/v1/slm/mtas                     ");
        writefln("    GET/PUT/DELETE   /api/v1/slm/mtas/*                   ");
        writefln("    GET              /api/v1/slm/operations                ");
        writefln("    GET              /api/v1/slm/operations/*              ");
        writefln("    POST             /api/v1/slm/operations/*/poll         ");
        writefln("    POST             /api/v1/slm/operations/*/abort        ");
        writefln("    GET              /api/v1/slm/operations/*/logs         ");
        writefln("    GET/POST         /api/v1/slm/subscriptions             ");
        writefln("    GET/DELETE       /api/v1/slm/subscriptions/*           ");
        writefln("                                                          ");
        writefln("  Health:                                                 ");
        writefln("    GET              /api/v1/health                       ");
        writefln("==========================================================");

        runApplication();
    }
}
