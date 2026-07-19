/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.buildcode;
mixin(ShowModule!());

@safe:
version (unittest) {
} else {
  void main() {
    auto config    = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    container.projectController.registerRoutes(router);
    container.devSpaceController.registerRoutes(router);
    container.templateController.registerRoutes(router);
    container.pipelineController.registerRoutes(router);
    container.buildJobController.registerRoutes(router);
    container.deploymentController.registerRoutes(router);
    container.aiRequestController.registerRoutes(router);
    container.serviceBindingController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    auto settings = new HTTPServerSettings();
    settings.port          = config.port;
    settings.bindAddresses = [config.host];

    auto listener = listenHTTP(settings, router);

    writefln("==========================================================");
    writefln("  SAP Build Code Platform Service                         ");
    writefln("  Listening on %s:%d", config.host, config.port);
    writefln("                                                          ");
    writefln("  Build Code API v1 Endpoints:                            ");
    writefln("    CRUD      /api/v1/buildcode/projects                  ");
    writefln("    CRUD      /api/v1/buildcode/devspaces                 ");
    writefln("    CRUD      /api/v1/buildcode/templates                 ");
    writefln("    CRUD      /api/v1/buildcode/pipelines                 ");
    writefln("    CRUD      /api/v1/buildcode/buildjobs                 ");
    writefln("    CRUD      /api/v1/buildcode/deployments               ");
    writefln("    POST      /api/v1/buildcode/ai/generate               ");
    writefln("    GET       /api/v1/buildcode/ai/requests               ");
    writefln("    CRUD      /api/v1/buildcode/servicebindings           ");
    writefln("                                                          ");
    writefln("  Health:                                                 ");
    writefln("    GET       /api/v1/health                              ");
    writefln("==========================================================");

    runApplication();
  }
}
