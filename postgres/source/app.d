/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.postgres;

@safe:

version (unittest) {
}
else {
    void main() {
        auto config    = loadConfig();
        auto container = buildContainer(config);

        auto router = new URLRouter();

        // Register all controllers
        container.serviceInstanceController.registerRoutes(router);
        container.serviceBindingController.registerRoutes(router);
        container.servicePlanController.registerRoutes(router);
        container.configurationController.registerRoutes(router);
        container.backupPolicyController.registerRoutes(router);
        container.databaseUserController.registerRoutes(router);
        container.databaseExtensionController.registerRoutes(router);
        container.maintenanceWindowController.registerRoutes(router);
        container.healthController.registerRoutes(router);

        writeln("====================================================");
        writeln("  SAP PostgreSQL Hyperscaler Adapter - UIM Platform");
        writeln("====================================================");
        writeln("  Endpoints:");
        writeln("    GET    /api/v1/postgres/instances");
        writeln("    POST   /api/v1/postgres/instances");
        writeln("    GET    /api/v1/postgres/instances/:id");
        writeln("    PUT    /api/v1/postgres/instances/:id");
        writeln("    DELETE /api/v1/postgres/instances/:id");
        writeln("    GET    /api/v1/postgres/bindings");
        writeln("    POST   /api/v1/postgres/bindings");
        writeln("    GET    /api/v1/postgres/bindings/:id");
        writeln("    DELETE /api/v1/postgres/bindings/:id");
        writeln("    GET    /api/v1/postgres/plans");
        writeln("    POST   /api/v1/postgres/plans");
        writeln("    GET    /api/v1/postgres/plans/:id");
        writeln("    PUT    /api/v1/postgres/plans/:id");
        writeln("    DELETE /api/v1/postgres/plans/:id");
        writeln("    GET    /api/v1/postgres/configurations");
        writeln("    POST   /api/v1/postgres/configurations");
        writeln("    GET    /api/v1/postgres/configurations/:id");
        writeln("    PUT    /api/v1/postgres/configurations/:id");
        writeln("    DELETE /api/v1/postgres/configurations/:id");
        writeln("    GET    /api/v1/postgres/backup-policies");
        writeln("    POST   /api/v1/postgres/backup-policies");
        writeln("    GET    /api/v1/postgres/backup-policies/:id");
        writeln("    PUT    /api/v1/postgres/backup-policies/:id");
        writeln("    DELETE /api/v1/postgres/backup-policies/:id");
        writeln("    GET    /api/v1/postgres/db-users");
        writeln("    POST   /api/v1/postgres/db-users");
        writeln("    GET    /api/v1/postgres/db-users/:id");
        writeln("    PUT    /api/v1/postgres/db-users/:id");
        writeln("    DELETE /api/v1/postgres/db-users/:id");
        writeln("    GET    /api/v1/postgres/extensions");
        writeln("    POST   /api/v1/postgres/extensions");
        writeln("    GET    /api/v1/postgres/extensions/:id");
        writeln("    DELETE /api/v1/postgres/extensions/:id");
        writeln("    GET    /api/v1/postgres/maintenance-windows");
        writeln("    POST   /api/v1/postgres/maintenance-windows");
        writeln("    GET    /api/v1/postgres/maintenance-windows/:id");
        writeln("    PUT    /api/v1/postgres/maintenance-windows/:id");
        writeln("    DELETE /api/v1/postgres/maintenance-windows/:id");
        writeln("    GET    /api/v1/health");
        writeln("====================================================");
        writeln("  Listening on ", config.host, ":", config.port);
        writeln("====================================================");

        auto settings = new HTTPServerSettings();
        settings.port          = config.port;
        settings.bindAddresses = [config.host];

        listenHTTP(settings, router);
        runApplication();
    }
}
