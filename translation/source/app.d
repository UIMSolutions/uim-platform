/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.translation;

// mixin(ShowModule!());

@safe:

version (unittest) {
} else {
    void main() {
        auto config = loadConfig();
        auto container = buildContainer(config);

        auto router = new URLRouter();

        // Register all controller routes (driving adapters)
        container.languageController.registerRoutes(router);
        container.domainController.registerRoutes(router);
        container.textTypeController.registerRoutes(router);
        container.translationController.registerRoutes(router);
        container.translationProjectController.registerRoutes(router);
        container.glossaryController.registerRoutes(router);
        container.documentTranslationController.registerRoutes(router);
        container.translationJobController.registerRoutes(router);
        container.healthController.registerRoutes(router);

        auto settings = new HTTPServerSettings();
        settings.port = config.port;
        settings.bindAddresses = [config.host];

        auto listener = listenHTTP(settings, router);

        writefln("==========================================================");
        writefln("  Translation Hub Service");
        writefln("  Listening on %s:%d", config.host, config.port);
        writefln("                                                          ");
        writefln("  Translation Hub API v1 Endpoints:                       ");
        writefln("    GET     /api/v1/translation/languages                 ");
        writefln("    GET     /api/v1/translation/domains                   ");
        writefln("    GET     /api/v1/translation/text-types                ");
        writefln("    POST    /api/v1/translation/translate                 ");
        writefln("    CRUD    /api/v1/translation/projects                  ");
        writefln("    CRUD    /api/v1/translation/glossaries                ");
        writefln("    POST    /api/v1/translation/documents/translate        ");
        writefln("    POST    /api/v1/translation/documents/translate/async  ");
        writefln("    POST    /api/v1/translation/jobs                      ");
        writefln("    GET     /api/v1/translation/jobs                      ");
        writefln("    GET     /api/v1/translation/jobs/*                    ");
        writefln("    POST    /api/v1/translation/jobs/*/cancel             ");
        writefln("                                                          ");
        writefln("  Health:                                                 ");
        writefln("    GET     /api/v1/health                               ");
        writefln("==========================================================");

        runApplication();
    }
}
