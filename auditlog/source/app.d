module app;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.core.core : runApplication;
// 
// import uim.platform.auditlog.infrastructure.config;
// import uim.platform.auditlog.infrastructure.container;
// 
// // import std.stdio : writefln;

import uim.platform.auditlog;
@safe:

void main() {
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Register all controller routes (driving adapters)
    container.auditLogController.registerRoutes(router);
    container.retentionController.registerRoutes(router);
    container.auditConfigController.registerRoutes(router);
    container.exportController.registerRoutes(router);
    container.securityEventController.registerRoutes(router);
    container.dataAccessController.registerRoutes(router);
    container.configChangeController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];

    auto listener = listenHTTP(settings, router);

    writefln("==========================================================");
    writefln("  AuditLog Service");
    writefln("  Listening on %s:%d", config.host, config.port);
    writefln("                                                          ");
    writefln("  Endpoints:                                              ");
    writefln("    POST/GET  /api/v1/auditlog                            ");
    writefln("    CRUD      /api/v1/retention                           ");
    writefln("    CRUD      /api/v1/configs                             ");
    writefln("    POST/GET  /api/v1/exports                             ");
    writefln("    POST      /api/v1/security-events                     ");
    writefln("    POST      /api/v1/data-access                         ");
    writefln("    POST      /api/v1/config-changes                      ");
    writefln("    GET       /api/v1/health                              ");
    writefln("==========================================================");

    runApplication();
}
