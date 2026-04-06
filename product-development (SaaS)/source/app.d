/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.product_development;

void main() {
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Register all controllers
    container.productController.registerRoutes(router);
    container.bomController.registerRoutes(router);
    container.changeRequestController.registerRoutes(router);
    container.documentController.registerRoutes(router);
    container.specificationController.registerRoutes(router);
    container.recipeController.registerRoutes(router);
    container.collaborationController.registerRoutes(router);
    container.productStructureController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    writeln("====================================================");
    writeln("  Product Development Service");
    writeln("====================================================");
    writeln("  Endpoints:");
    writeln("    GET    /api/v1/product-development/products");
    writeln("    POST   /api/v1/product-development/products");
    writeln("    GET    /api/v1/product-development/products/:id");
    writeln("    PUT    /api/v1/product-development/products/:id");
    writeln("    DELETE /api/v1/product-development/products/:id");
    writeln("    GET    /api/v1/product-development/boms");
    writeln("    POST   /api/v1/product-development/boms");
    writeln("    GET    /api/v1/product-development/boms/:id");
    writeln("    PUT    /api/v1/product-development/boms/:id");
    writeln("    DELETE /api/v1/product-development/boms/:id");
    writeln("    GET    /api/v1/product-development/change-requests");
    writeln("    POST   /api/v1/product-development/change-requests");
    writeln("    GET    /api/v1/product-development/change-requests/:id");
    writeln("    PUT    /api/v1/product-development/change-requests/:id");
    writeln("    DELETE /api/v1/product-development/change-requests/:id");
    writeln("    GET    /api/v1/product-development/documents");
    writeln("    POST   /api/v1/product-development/documents");
    writeln("    GET    /api/v1/product-development/documents/:id");
    writeln("    PUT    /api/v1/product-development/documents/:id");
    writeln("    DELETE /api/v1/product-development/documents/:id");
    writeln("    GET    /api/v1/product-development/specifications");
    writeln("    POST   /api/v1/product-development/specifications");
    writeln("    GET    /api/v1/product-development/specifications/:id");
    writeln("    PUT    /api/v1/product-development/specifications/:id");
    writeln("    DELETE /api/v1/product-development/specifications/:id");
    writeln("    GET    /api/v1/product-development/recipes");
    writeln("    POST   /api/v1/product-development/recipes");
    writeln("    GET    /api/v1/product-development/recipes/:id");
    writeln("    PUT    /api/v1/product-development/recipes/:id");
    writeln("    DELETE /api/v1/product-development/recipes/:id");
    writeln("    GET    /api/v1/product-development/collaborations");
    writeln("    POST   /api/v1/product-development/collaborations");
    writeln("    GET    /api/v1/product-development/collaborations/:id");
    writeln("    PUT    /api/v1/product-development/collaborations/:id");
    writeln("    DELETE /api/v1/product-development/collaborations/:id");
    writeln("    GET    /api/v1/product-development/structures");
    writeln("    POST   /api/v1/product-development/structures");
    writeln("    GET    /api/v1/product-development/structures/:id");
    writeln("    PUT    /api/v1/product-development/structures/:id");
    writeln("    DELETE /api/v1/product-development/structures/:id");
    writeln("    GET    /health");
    writeln("====================================================");
    writefln("  Listening on %s:%d", config.host, config.port);
    writeln("====================================================");

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];
    auto listener = listenHTTP(settings, router);
    scope (exit) listener.stopListening();
    runApplication();
}
