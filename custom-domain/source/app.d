/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:
version (unittest) {
} else {
    void main() {
        auto config = loadConfig();
        auto container = buildContainer(config);

        auto router = new URLRouter();

        // Register all controller routes (driving adapters)
        container.domainController.registerRoutes(router);
        container.keyController.registerRoutes(router);
        container.certController.registerRoutes(router);
        container.tlsController.registerRoutes(router);
        container.mappingController.registerRoutes(router);
        container.trustedCertController.registerRoutes(router);
        container.dnsController.registerRoutes(router);
        container.dashboardController.registerRoutes(router);
        container.healthController.registerRoutes(router);

        auto settings = new HTTPServerSettings();
        settings.port = config.port;
        settings.bindAddresses = [config.host];

        auto listener = listenHTTP(settings, router);

        writefln("==========================================================");
        writefln("  Custom Domain Service");
        writefln("  Listening on %s:%d", config.host, config.port);
        writefln("                                                          ");
        writefln("  Custom Domain API v1 Endpoints:                         ");
        writefln("    CRUD+A /api/v1/custom-domain/domains                  ");
        writefln("    CR+D   /api/v1/custom-domain/keys                     ");
        writefln("    CRUD+A /api/v1/custom-domain/certificates             ");
        writefln("    CRUD   /api/v1/custom-domain/tls-configurations       ");
        writefln("    CR+D   /api/v1/custom-domain/mappings                 ");
        writefln("    CR+D   /api/v1/custom-domain/trusted-certificates     ");
        writefln("    CRUD   /api/v1/custom-domain/dns-records              ");
        writefln("    GET+R  /api/v1/custom-domain/dashboard                ");
        writefln("                                                          ");
        writefln("  Health:                                                 ");
        writefln("    GET    /api/v1/health                                 ");
        writefln("==========================================================");

        runApplication();
    }
}
