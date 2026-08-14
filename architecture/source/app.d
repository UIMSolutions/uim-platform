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

        router.registerRestInterface(new ArchitectureBlocksService(container.manageArchitectureBlocks), "/rest/v1/architecture-blocks/");
        router.registerRestInterface(new BusinessBlocksService(container.manageBusinessBlocks), "/rest/v1/business-blocks/");
        router.registerRestInterface(new DataBlocksService(container.manageDataBlocks), "/rest/v1/data-blocks/");
        router.registerRestInterface(new SolutionBlocksService(container.manageSolutionBlocks), "/rest/v1/solution-blocks/");
        router.registerRestInterface(new TechnologyBlocksService(container.manageTechnologyBlocks), "/rest/v1/technology-blocks/");
        foreach (route; router.getAllRoutes()) {
            writeln("Methode: ", route.method, ", Pfad: ", route.pattern);
        }

        // # Register all controllers
        container.healthController.registerRoutes(router);
        container.buildingBlockPwaController.registerRoutes(router);
        container.buildingBlockWebController.registerRoutes(router);

        /// # Register UI5 controllers
        container.overviewUi5Controller.registerRoutes(router);
        container.buildingBlockUi5Controller.registerRoutes(router);
        container.architectureBlocksUi5Controller.registerRoutes(router);

        auto settings = new HTTPServerSettings();
        settings.bindAddresses = [config.host];
        settings.port = config.port;

        writeln("======================================================");
        writeln("  UIM TOGAF Building Blocks Platform Service");
        writeln("  Listening on http://", config.host, ":", config.port);
        writeln("  Health: /api/v1/health");
        writeln("  API base: /api/v1/building-blocks");
        writeln("  PWA UI: /pwa/architecture?tenantId=default");
        writeln("  UI5 UI: /ui5/architecture?tenantId=default");
        writeln("  Web UI: /web/architecture?tenantId=default");
        writeln("======================================================");

        listenHTTP(settings, router);
        runApplication();
    }
}
