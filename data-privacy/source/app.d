/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.core.core : runApplication;

// import uim.platform.data.privacy.infrastructure.config;
// import uim.platform.data.privacy.infrastructure.container;

// import std.stdio : writefln;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:

version (unittest) {
} else {
  void main() {
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Register all controller routes (driving adapters)
    container.dataSubjectController.registerRoutes(router);
    container.personalDataModelController.registerRoutes(router);
    container.deletionController.registerRoutes(router);
    container.blockingController.registerRoutes(router);
    container.legalGroundController.registerRoutes(router);
    container.retentionRuleController.registerRoutes(router);
    container.consentController.registerRoutes(router);
    container.dataRetrievalController.registerRoutes(router);
    container.healthController.registerRoutes(router);
    container.dataControllerController.registerRoutes(router);
    container.dataControllerGroupController.registerRoutes(router);
    container.businessContextController.registerRoutes(router);
    container.businessProcessController.registerRoutes(router);
    container.businessSubprocessController.registerRoutes(router);
    container.correctionRequestController.registerRoutes(router);
    container.archiveRequestController.registerRoutes(router);
    container.destructionRequestController.registerRoutes(router);
    container.purposeRecordController.registerRoutes(router);
    container.consentPurposeController.registerRoutes(router);
    container.ruleSetController.registerRoutes(router);
    container.informationReportController.registerRoutes(router);
    container.anonymizationConfigController.registerRoutes(router);

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];

    auto listener = listenHTTP(settings, router);

    writefln("==========================================================");
    writefln("  Data Privacy Integration Service");
    writefln("  Listening on %s:%d", config.host, config.port);
    writefln("                                                          ");
    writefln("  Endpoints:                                              ");
    writefln("    CRUD  /api/v1/data-subjects                           ");
    writefln("    CRUD  /api/v1/personal-data-models                    ");
    writefln("    CRUD  /api/v1/deletion-requests                       ");
    writefln("    CRUD  /api/v1/blocking-requests                       ");
    writefln("    CRUD  /api/v1/legal-grounds                           ");
    writefln("    CRUD  /api/v1/retention-rules                         ");
    writefln("    CRUD  /api/v1/consents                                ");
    writefln("    CRUD  /api/v1/data-retrievals                         ");
    writefln("    CRUD  /api/v1/data-controllers                        ");
    writefln("    CRUD  /api/v1/controller-groups                       ");
    writefln("    CRUD  /api/v1/business-contexts                       ");
    writefln("    CRUD  /api/v1/business-processes                      ");
    writefln("    CRUD  /api/v1/business-subprocesses                   ");
    writefln("    CRUD  /api/v1/correction-requests                     ");
    writefln("    CRUD  /api/v1/archive-requests                        ");
    writefln("    CRUD  /api/v1/destruction-requests                    ");
    writefln("    CRUD  /api/v1/purpose-records                         ");
    writefln("    CRUD  /api/v1/consent-purposes                        ");
    writefln("    CRUD  /api/v1/rule-sets                               ");
    writefln("    CRUD  /api/v1/information-reports                     ");
    writefln("    CRUD  /api/v1/anonymization-configs                   ");
    writefln("    GET   /api/v1/health                                  ");
    writefln("==========================================================");

    runApplication();
  }
}
