module app;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:
version (unittest) {
} else {
    void main() {
        auto config = loadConfig();
        auto container = buildContainer(config);

        auto router = new URLRouter();

        // Register all controllers
        container.environmentController.registerRoutes(router);
        container.serviceBrokerController.registerRoutes(router);
        container.serviceOfferingController.registerRoutes(router);
        container.servicePlanController.registerRoutes(router);
        container.serviceInstanceController.registerRoutes(router);
        container.serviceBindingController.registerRoutes(router);
        container.operationController.registerRoutes(router);
        container.labelController.registerRoutes(router);
        container.healthController.registerRoutes(router);

        writeln("====================================================");
        writeln("  Service Manager Service");
        writeln("====================================================");
        writeln("  Endpoints:");
        writeln("    GET    /api/v1/service-manager/platforms");
        writeln("    POST   /api/v1/service-manager/platforms");
        writeln("    GET    /api/v1/service-manager/platforms/:id");
        writeln("    PUT    /api/v1/service-manager/platforms/:id");
        writeln("    DELETE /api/v1/service-manager/platforms/:id");
        writeln("    GET    /api/v1/service-manager/service-brokers");
        writeln("    POST   /api/v1/service-manager/service-brokers");
        writeln("    GET    /api/v1/service-manager/service-brokers/:id");
        writeln("    PUT    /api/v1/service-manager/service-brokers/:id");
        writeln("    DELETE /api/v1/service-manager/service-brokers/:id");
        writeln("    GET    /api/v1/service-manager/service-offerings");
        writeln("    POST   /api/v1/service-manager/service-offerings");
        writeln("    GET    /api/v1/service-manager/service-offerings/:id");
        writeln("    PUT    /api/v1/service-manager/service-offerings/:id");
        writeln("    DELETE /api/v1/service-manager/service-offerings/:id");
        writeln("    GET    /api/v1/service-manager/service-plans");
        writeln("    POST   /api/v1/service-manager/service-plans");
        writeln("    GET    /api/v1/service-manager/service-plans/:id");
        writeln("    PUT    /api/v1/service-manager/service-plans/:id");
        writeln("    DELETE /api/v1/service-manager/service-plans/:id");
        writeln("    GET    /api/v1/service-manager/service-instances");
        writeln("    POST   /api/v1/service-manager/service-instances");
        writeln("    GET    /api/v1/service-manager/service-instances/:id");
        writeln("    PUT    /api/v1/service-manager/service-instances/:id");
        writeln("    DELETE /api/v1/service-manager/service-instances/:id");
        writeln("    GET    /api/v1/service-manager/service-bindings");
        writeln("    POST   /api/v1/service-manager/service-bindings");
        writeln("    GET    /api/v1/service-manager/service-bindings/:id");
        writeln("    PUT    /api/v1/service-manager/service-bindings/:id");
        writeln("    DELETE /api/v1/service-manager/service-bindings/:id");
        writeln("    GET    /api/v1/service-manager/operations");
        writeln("    POST   /api/v1/service-manager/operations");
        writeln("    GET    /api/v1/service-manager/operations/:id");
        writeln("    PUT    /api/v1/service-manager/operations/:id");
        writeln("    DELETE /api/v1/service-manager/operations/:id");
        writeln("    GET    /api/v1/service-manager/labels");
        writeln("    POST   /api/v1/service-manager/labels");
        writeln("    GET    /api/v1/service-manager/labels/:id");
        writeln("    PUT    /api/v1/service-manager/labels/:id");
        writeln("    DELETE /api/v1/service-manager/labels/:id");
        writeln("    GET    /health");
        writeln("====================================================");
        writefln("  Listening on %s:%d", config.host, config.port);
        writeln("====================================================");

        auto settings = new HTTPServerSettings();
        settings.port = config.port;
        settings.bindAddresses = [config.host];
        auto listener = listenHTTP(settings, router);
        scope (exit)
            listener.stopListening();
        runApplication();
    }
}
