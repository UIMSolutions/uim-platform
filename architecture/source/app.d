module app;

import uim.platform.architecture;

@safe:

version (unittest) {
} else {
    void main() {
        import std.stdio : writeln;

        auto config = loadConfig();
        auto container = buildContainer(config);
        auto router = new URLRouter();

        router.registerRestInterface(new TechnologyBlocksService(container.manageTechnologyBlocks), "/rest/v1/");
        foreach (route; router.getAllRoutes()) {
            writeln("Methode: ", route.method, ", Pfad: ", route.pattern);
        }

        // # Register all controllers
        container.healthController.registerRoutes(router);
        container.buildingBlockPwaController.registerRoutes(router);
        container.buildingBlockWebController.registerRoutes(router);

        auto settings = new HTTPServerSettings();
        settings.bindAddresses = [config.host];
        settings.port = config.port;

        writeln("======================================================");
        writeln("  UIM TOGAF Building Blocks Platform Service");
        writeln("  Listening on http://", config.host, ":", config.port);
        writeln("  Health: /api/v1/health");
        writeln("  API base: /api/v1/building-blocks");
        writeln("  PWA UI: /pwa/architecture?tenantId=default");
        writeln("  Web UI: /web/architecture?tenantId=default");
        writeln("======================================================");

        listenHTTP(settings, router);
        runApplication();
    }
}
