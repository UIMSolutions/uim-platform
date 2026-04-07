/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.document_ai.infrastructure.config;
import uim.platform.document_ai.infrastructure.container;

@safe:

version (unittest) {
} ) {
    void main() {
        auto config = loadConfig();
        auto container = buildContainer(config);

        auto router = new URLRouter();

        // Register all controller routes (driving adapters)
        container.documentController.registerRoutes(router);
        container.schemaController.registerRoutes(router);
        container.templateController.registerRoutes(router);
        container.documentTypeController.registerRoutes(router);
        container.enrichmentDataController.registerRoutes(router);
        container.trainingJobController.registerRoutes(router);
        container.clientController.registerRoutes(router);
        container.capabilitiesController.registerRoutes(router);
        container.healthController.registerRoutes(router);

        auto settings = new HTTPServerSettings();
        settings.port = config.port;
        settings.bindAddresses = [config.host];

        auto listener = listenHTTP(settings, router);

        writefln("==========================================================");
        writefln("  Document AI Service");
        writefln("  Listening on %s:%d", config.host, config.port);
        writefln("                                                          ");
        writefln("  Document Processing Endpoints:                          ");
        writefln("    POST      /api/v1/document/jobs         (Upload)      ");
        writefln("    GET       /api/v1/document/jobs         (List)        ");
        writefln("    GET       /api/v1/document/jobs/*        (Get)        ");
        writefln("    DELETE    /api/v1/document/jobs/*        (Delete)     ");
        writefln("    POST      /api/v1/document/jobs/*/confirm             ");
        writefln("    GET       /api/v1/document/jobs/*/results             ");
        writefln("                                                          ");
        writefln("  Schema Management:                                      ");
        writefln("    CRUD      /api/v1/schemas                             ");
        writefln("                                                          ");
        writefln("  Template Management:                                    ");
        writefln("    CRUD      /api/v1/templates                           ");
        writefln("                                                          ");
        writefln("  Document Types:                                         ");
        writefln("    CRUD      /api/v1/document-types                      ");
        writefln("                                                          ");
        writefln("  Enrichment Data:                                        ");
        writefln("    CRUD      /api/v1/enrichment-data                     ");
        writefln("                                                          ");
        writefln("  Training:                                               ");
        writefln("    CRUD+PATCH /api/v1/training/jobs                      ");
        writefln("                                                          ");
        writefln("  Admin:                                                  ");
        writefln("    CRUD+PATCH /api/v1/admin/clients                      ");
        writefln("                                                          ");
        writefln("  Capabilities and Health:                                ");
        writefln("    GET       /api/v1/capabilities                        ");
        writefln("    GET       /api/v1/health                              ");
        writefln("==========================================================");

        runApplication();
    }
}
