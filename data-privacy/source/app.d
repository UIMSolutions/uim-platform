module app;

// import vibe.http.server;
import vibe.http.router;
import vibe.core.core : runApplication;

import uim.platform.data.privacy.infrastructure.config;
import uim.platform.data.privacy.infrastructure.container;

import std.stdio : writefln;
@safe:

version (unittest) {
} else {
void main() {
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Register all controller routes (driving adapters)
    container.dataSubjectController.registerRoutes(router);
    container.personalDataModelController.registerRoutes(router);
    container.deletionController.registerRoutes(router);
    container.blockingController.registerRoutes(router);
    container.legalGroundController.registerRoutes(router);
    container.retentionRuleController.registerRoutes(router);
    container.consentController.registerRoutes(router);
    container.dataRetrievalController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];

    auto listener = listenHTTP(settings, router);

    writefln("==========================================================");
    writefln("  Data Privacy Integration Service");
    writefln("  Listening on %s:%d", config.host, config.port);
    writefln("                                                          ");
    writefln("  Endpoints:                                              ");
    writefln("    CRUD  /api/v1/data-subjects                           ");
    writefln("    CRUD  /api/v1/personal-data-models                    ");
    writefln("    CRUD  /api/v1/deletion-requests                       ");
    writefln("    CRUD  /api/v1/blocking-requests                       ");
    writefln("    CRUD  /api/v1/legal-grounds                           ");
    writefln("    CRUD  /api/v1/retention-rules                         ");
    writefln("    CRUD  /api/v1/consents                                ");
    writefln("    CRUD  /api/v1/data-retrievals                         ");
    writefln("    GET   /api/v1/health                                  ");
    writefln("==========================================================");

    runApplication();
}
