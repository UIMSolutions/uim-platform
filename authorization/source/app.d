module app;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

version (unittest) {
} else {
  void main() {
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    container.webController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];

    listenHTTP(settings, router);

    writefln("==============================================================");
    writefln("  Authorization Management Service (AMS-compatible)");
    writefln("  Listening on %s:%d", config.host, config.port);
    writefln("  Storage backend: %s", config.storageBackend);
    writefln("  Endpoints:");
    writefln("    GET                  /api/v1/health");
    writefln("    GET                  /api/v1/web");
    writefln("    POST/GET/PUT/DELETE  /api/v1/applications");
    writefln("    POST/GET/PUT/DELETE  /api/v1/application-apis");
    writefln("    POST/GET/PUT/DELETE  /api/v1/policies");
    writefln("    POST/GET/DELETE      /api/v1/policy-assignments");
    writefln("    POST                 /api/v1/authorization/evaluate");
    writefln("==============================================================");

    runApplication();
  }
}
