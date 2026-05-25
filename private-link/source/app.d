module app;
import uim.platform.private_link;

@safe:

version (unittest) {}
else {
  void main() {
    import std.stdio : writeln;

    auto config = loadConfig();
    auto container = buildContainer(config);
    auto router = new URLRouter();

    container.instanceController.registerRoutes(router);
    container.endpointController.registerRoutes(router);
    container.bindingController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];

    writeln("╔══════════════════════════════════════════════════════════╗");
    writeln("║           SAP Private Link Service (UIM Platform)       ║");
    writeln("║  Hexagonal Architecture  •  vibe.d  •  D Language       ║");
    writeln("╚══════════════════════════════════════════════════════════╝");
    writeln("  Listening on ", config.host, ":", config.port);
    writeln("  Health:    GET /api/v1/health");
    writeln("  Instances: /api/v1/service-instances");
    writeln("  Endpoints: /api/v1/private-endpoints");
    writeln("  Bindings:  /api/v1/service-bindings");

    listenHTTP(settings, router);
    runApplication();
  }
}
