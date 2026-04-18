/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.data_retention;

void main() {
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Register all controller routes (driving adapters)
    container.businessPurposeController.registerRoutes(router);
    container.legalGroundController.registerRoutes(router);
    container.retentionRuleController.registerRoutes(router);
    container.residenceRuleController.registerRoutes(router);
    container.dataSubjectController.registerRoutes(router);
    container.deletionRequestController.registerRoutes(router);
    container.archivingJobController.registerRoutes(router);
    container.applicationGroupController.registerRoutes(router);
    container.legalEntityController.registerRoutes(router);
    container.dataSubjectRoleController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    writeln("==========================================================");
    writeln("  Data Retention Manager Service");
    writeln("==========================================================");
    writeln("  Endpoints:");
    writeln("    CRUD      /api/v1/data-retention/business-purposes");
    writeln("    POST      /api/v1/data-retention/business-purposes/*/activate");
    writeln("    CRUD      /api/v1/data-retention/legal-grounds");
    writeln("    CRUD      /api/v1/data-retention/retention-rules");
    writeln("    CRUD      /api/v1/data-retention/residence-rules");
    writeln("    CRUD      /api/v1/data-retention/data-subjects");
    writeln("    POST      /api/v1/data-retention/data-subjects/*/block");
    writeln("    CRUD      /api/v1/data-retention/deletion-requests");
    writeln("    CRUD      /api/v1/data-retention/archiving-jobs");
    writeln("    CRUD      /api/v1/data-retention/application-groups");
    writeln("    CRUD      /api/v1/data-retention/legal-entities");
    writeln("    CRUD      /api/v1/data-retention/data-subject-roles");
    writeln("    GET       /api/v1/health");
    writeln("==========================================================");
    writefln("  Listening on %s:%d", config.host, config.port);
    writeln("==========================================================");

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];
    auto listener = listenHTTP(settings, router);
    scope (exit) listener.stopListening();
    runApplication();
}
