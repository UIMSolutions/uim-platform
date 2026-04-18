/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.data_retention.infrastructure.config;
import uim.platform.data_retention.infrastructure.container;

@safe:

version (unittest) {
} else {
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

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];

    auto listener = listenHTTP(settings, router);

    writefln("==========================================================");
    writefln("  Data Retention Manager Service");
    writefln("  Listening on %s:%d", config.host, config.port);
    writefln("                                                          ");
    writefln("  Endpoints:                                              ");
    writefln("    CRUD      /api/v1/data-retention/business-purposes    ");
    writefln("    POST      /api/v1/data-retention/business-purposes/*/activate");
    writefln("    CRUD      /api/v1/data-retention/legal-grounds        ");
    writefln("    CRUD      /api/v1/data-retention/retention-rules      ");
    writefln("    CRUD      /api/v1/data-retention/residence-rules      ");
    writefln("    CRUD      /api/v1/data-retention/data-subjects        ");
    writefln("    POST      /api/v1/data-retention/data-subjects/*/block");
    writefln("    CRUD      /api/v1/data-retention/deletion-requests    ");
    writefln("    CRUD      /api/v1/data-retention/archiving-jobs       ");
    writefln("    CRUD      /api/v1/data-retention/application-groups   ");
    writefln("    CRUD      /api/v1/data-retention/legal-entities       ");
    writefln("    CRUD      /api/v1/data-retention/data-subject-roles   ");
    writefln("    GET       /api/v1/health                              ");
    writefln("==========================================================");

    runApplication();
  }
}
