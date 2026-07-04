/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.saas_provisioning;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerSettings, listenHTTP;
import vibe.core.core : runApplication;
import std.stdio : writefln;

mixin(ShowModule!());

@safe:

version (unittest) {
} else {
    void main() {
        auto config = loadConfig();
        auto container = buildContainer(config);

        auto router = new URLRouter();
        container.saasApplicationController.registerRoutes(router);
        container.appSubscriptionController.registerRoutes(router);
        container.subscriptionJobController.registerRoutes(router);
        container.healthController.registerRoutes(router);

        auto settings = new HTTPServerSettings();
        settings.port = config.port;
        settings.bindAddresses = [config.host];

        auto listener = listenHTTP(settings, router);

        writefln("==========================================================");
        writefln("  SAP SaaS Provisioning Service");
        writefln("  Listening on %s:%d", config.host, config.port);
        writefln("                                                          ");
        writefln("  API v1 Endpoints:                                       ");
        writefln("    GET/POST        /api/v1/saas-provisioning/applications ");
        writefln("    GET/PUT/DELETE  /api/v1/saas-provisioning/applications/*");
        writefln("    GET/POST        /api/v1/saas-provisioning/subscriptions");
        writefln("    GET/PUT/DELETE  /api/v1/saas-provisioning/subscriptions/*");
        writefln("    GET             /api/v1/saas-provisioning/jobs         ");
        writefln("    GET             /api/v1/saas-provisioning/jobs/*       ");
        writefln("    GET             /api/v1/health                         ");
        writefln("==========================================================");

        runApplication();
    }
}
