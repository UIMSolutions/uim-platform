/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.masterdata_governance;

@safe:

version (unittest) {
}
else {
  void main() {
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Register all controllers
    container.businessPartnerController.registerRoutes(router);
    container.changeRequestController.registerRoutes(router);
    container.dataQualityRuleController.registerRoutes(router);
    container.dataQualityScoreController.registerRoutes(router);
    container.replicationController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    writeln("====================================================");
    writeln("  SAP Master Data Governance, Cloud Edition");
    writeln("====================================================");
    writeln("  Endpoints:");
    writeln("    GET    /api/v1/masterdata-governance/business-partners");
    writeln("    POST   /api/v1/masterdata-governance/business-partners");
    writeln("    GET    /api/v1/masterdata-governance/business-partners/:id");
    writeln("    PUT    /api/v1/masterdata-governance/business-partners/:id");
    writeln("    DELETE /api/v1/masterdata-governance/business-partners/:id");
    writeln("    GET    /api/v1/masterdata-governance/change-requests");
    writeln("    POST   /api/v1/masterdata-governance/change-requests");
    writeln("    GET    /api/v1/masterdata-governance/change-requests/:id");
    writeln("    PUT    /api/v1/masterdata-governance/change-requests/:id");
    writeln("    DELETE /api/v1/masterdata-governance/change-requests/:id");
    writeln("    GET    /api/v1/masterdata-governance/data-quality-rules");
    writeln("    POST   /api/v1/masterdata-governance/data-quality-rules");
    writeln("    GET    /api/v1/masterdata-governance/data-quality-rules/:id");
    writeln("    PUT    /api/v1/masterdata-governance/data-quality-rules/:id");
    writeln("    DELETE /api/v1/masterdata-governance/data-quality-rules/:id");
    writeln("    GET    /api/v1/masterdata-governance/data-quality-scores");
    writeln("    POST   /api/v1/masterdata-governance/data-quality-scores");
    writeln("    GET    /api/v1/masterdata-governance/data-quality-scores/:id");
    writeln("    PUT    /api/v1/masterdata-governance/data-quality-scores/:id");
    writeln("    DELETE /api/v1/masterdata-governance/data-quality-scores/:id");
    writeln("    GET    /api/v1/masterdata-governance/replications");
    writeln("    POST   /api/v1/masterdata-governance/replications");
    writeln("    GET    /api/v1/masterdata-governance/replications/:id");
    writeln("    PUT    /api/v1/masterdata-governance/replications/:id");
    writeln("    DELETE /api/v1/masterdata-governance/replications/:id");
    writeln("    GET    /health");
    writeln("====================================================");
    writefln("  Listening on %s:%d", config.host, config.port);
    writeln("====================================================");

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];

    listenHTTP(settings, router);
    runApplication();
  }
}
