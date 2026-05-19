/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.redis;

@safe:

version (unittest) {
}
else {
    void main() {
        auto config = loadConfig();
        auto container = buildContainer(config);

        auto router = new URLRouter();

        // Register all controllers
        container.serviceInstanceController.registerRoutes(router);
        container.serviceBindingController.registerRoutes(router);
        container.servicePlanController.registerRoutes(router);
        container.configurationController.registerRoutes(router);
        container.cacheEntryController.registerRoutes(router);
        container.metricController.registerRoutes(router);
        container.backupPolicyController.registerRoutes(router);
        container.accessControlController.registerRoutes(router);
        container.healthController.registerRoutes(router);

        writeln("====================================================");
        writeln("  SAP Redis on BTP, Hyperscaler Option");
        writeln("====================================================");
        writeln("  Endpoints:");
        writeln("    GET    /api/v1/redis/instances");
        writeln("    POST   /api/v1/redis/instances");
        writeln("    GET    /api/v1/redis/instances/:id");
        writeln("    PUT    /api/v1/redis/instances/:id");
        writeln("    DELETE /api/v1/redis/instances/:id");
        writeln("    GET    /api/v1/redis/bindings");
        writeln("    POST   /api/v1/redis/bindings");
        writeln("    GET    /api/v1/redis/bindings/:id");
        writeln("    DELETE /api/v1/redis/bindings/:id");
        writeln("    GET    /api/v1/redis/plans");
        writeln("    POST   /api/v1/redis/plans");
        writeln("    GET    /api/v1/redis/plans/:id");
        writeln("    PUT    /api/v1/redis/plans/:id");
        writeln("    DELETE /api/v1/redis/plans/:id");
        writeln("    GET    /api/v1/redis/configurations");
        writeln("    POST   /api/v1/redis/configurations");
        writeln("    GET    /api/v1/redis/configurations/:id");
        writeln("    PUT    /api/v1/redis/configurations/:id");
        writeln("    DELETE /api/v1/redis/configurations/:id");
        writeln("    GET    /api/v1/redis/cache-entries");
        writeln("    POST   /api/v1/redis/cache-entries");
        writeln("    GET    /api/v1/redis/cache-entries/:id");
        writeln("    PUT    /api/v1/redis/cache-entries/:id");
        writeln("    DELETE /api/v1/redis/cache-entries/:id");
        writeln("    GET    /api/v1/redis/metrics");
        writeln("    POST   /api/v1/redis/metrics");
        writeln("    GET    /api/v1/redis/metrics/:id");
        writeln("    DELETE /api/v1/redis/metrics/:id");
        writeln("    GET    /api/v1/redis/backup-policies");
        writeln("    POST   /api/v1/redis/backup-policies");
        writeln("    GET    /api/v1/redis/backup-policies/:id");
        writeln("    PUT    /api/v1/redis/backup-policies/:id");
        writeln("    DELETE /api/v1/redis/backup-policies/:id");
        writeln("    GET    /api/v1/redis/access-controls");
        writeln("    POST   /api/v1/redis/access-controls");
        writeln("    GET    /api/v1/redis/access-controls/:id");
        writeln("    PUT    /api/v1/redis/access-controls/:id");
        writeln("    DELETE /api/v1/redis/access-controls/:id");
        writeln("    GET    /health");
        writeln("====================================================");
        writeln("  Listening on ", config.host, ":", config.port);
        writeln("====================================================");

        auto settings = new HTTPServerSettings();
        settings.port = config.port;
        settings.bindAddresses = [config.host];

        listenHTTP(settings, router);
        runApplication();
    }
}
