module app;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.core.core : runApplication;

import uim.platform.object_store.infrastructure.config;
import uim.platform.object_store.infrastructure.container;

// import std.stdio : writefln;

version (unittest) {
} else {
  void main() {
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Register all controller routes (driving adapters)
    container.bucketController.registerRoutes(router);
    container.objectController.registerRoutes(router);
    container.accessPolicyController.registerRoutes(router);
    container.lifecycleRuleController.registerRoutes(router);
    container.corsRuleController.registerRoutes(router);
    container.serviceBindingController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];

    auto listener = listenHTTP(settings, router);

    writefln("==========================================================");
    writefln("  Object Store Service");
    writefln("  Listening on %s:%d", config.host, config.port);
    writefln("                                                          ");
    writefln("  Endpoints:                                              ");
    writefln("    CRUD      /api/v1/buckets                             ");
    writefln("    CRUD      /api/v1/objects                             ");
    writefln("    POST      /api/v1/objects/copy                        ");
    writefln("    GET       /api/v1/objects/{id}/versions               ");
    writefln("    CRUD      /api/v1/access-policies                     ");
    writefln("    CRUD      /api/v1/lifecycle-rules                     ");
    writefln("    CRUD      /api/v1/cors-rules                          ");
    writefln("    CRUD      /api/v1/service-bindings                    ");
    writefln("    POST      /api/v1/service-bindings/{id}/revoke        ");
    writefln("    GET       /api/v1/health                              ");
    writefln("==========================================================");

    runApplication();
  }
}
