module app;
import uim.platform.integration_suite;

mixin(ShowModule!());

@safe:

version (unittest) {
}
else {
  void main() {
    auto config    = loadConfig();
    auto container = buildContainer(config);
    auto router    = new URLRouter();

    // === Integration Content (Cloud Integration) ===
    container.packageController.registerRoutes(router);
    container.flowController.registerRoutes(router);
    container.mappingController.registerRoutes(router);

    // === API Management ===
    container.apiProxyController.registerRoutes(router);
    container.apiProductController.registerRoutes(router);

    // === Event Mesh (Advanced Event Mesh) ===
    container.queueController.registerRoutes(router);
    container.subscriptionController.registerRoutes(router);

    // === B2B / Trading Partner Management ===
    container.partnerController.registerRoutes(router);

    // === User Management ===
    container.userController.registerRoutes(router);

    // === Health ===
    container.healthController.registerRoutes(router);

    auto settings = new HTTPServerSettings();
    settings.port          = config.port;
    settings.bindAddresses = [config.host];

    listenHTTP(settings, router);

    writefln("=============================================================");
    writefln("  SAP Integration Suite Platform Service");
    writefln("  Listening on %s:%d", config.host, config.port);
    writefln("                                                             ");
    writefln("  Cloud Integration                                          ");
    writefln("    CRUD    /api/v1/integration/packages                     ");
    writefln("    CRUD    /api/v1/integration/flows                        ");
    writefln("    POST    /api/v1/integration/flows/deploy/:id             ");
    writefln("    CRUD    /api/v1/integration/mappings                     ");
    writefln("                                                             ");
    writefln("  API Management                                             ");
    writefln("    CRUD    /api/v1/apimanagement/proxies                    ");
    writefln("    POST    /api/v1/apimanagement/proxies/publish/:id        ");
    writefln("    CRUD    /api/v1/apimanagement/products                   ");
    writefln("    POST    /api/v1/apimanagement/products/publish/:id       ");
    writefln("                                                             ");
    writefln("  Event Mesh                                                 ");
    writefln("    CRUD    /api/v1/eventmesh/queues                         ");
    writefln("    CRUD    /api/v1/eventmesh/subscriptions                  ");
    writefln("                                                             ");
    writefln("  B2B / Trading Partners                                     ");
    writefln("    CRUD    /api/v1/b2b/partners                             ");
    writefln("                                                             ");
    writefln("  Health                                                     ");
    writefln("    GET     /api/v1/health                                   ");
    writefln("=============================================================");

    runApplication();
  }
}
