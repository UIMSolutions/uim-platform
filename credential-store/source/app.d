/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.credential_store.infrastructure.config;
import uim.platform.credential_store.infrastructure.container;

@safe:

version (unittest) {
} else {
  void main() {
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Register all controller routes (driving adapters)
    container.namespaceController.registerRoutes(router);
    container.credentialController.registerRoutes(router);
    container.keyringController.registerRoutes(router);
    container.encryptionController.registerRoutes(router);
    container.bindingController.registerRoutes(router);
    container.auditController.registerRoutes(router);
    container.overviewController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];

    auto listener = listenHTTP(settings, router);

    writefln("==========================================================");
    writefln("  Credential Store Service");
    writefln("  Listening on %s:%d", config.host, config.port);
    writefln("                                                          ");
    writefln("  Endpoints:                                              ");
    writefln("    CRUD      /api/v1/namespaces                          ");
    writefln("    CRUD      /api/v1/passwords                           ");
    writefln("    CRUD      /api/v1/keys                                ");
    writefln("    CRUD      /api/v1/keyrings                            ");
    writefln("    POST      /api/v1/keyrings/rotate                     ");
    writefln("    POST      /api/v1/keyrings/disable                    ");
    writefln("    POST      /api/v1/encryption/generate                 ");
    writefln("    POST      /api/v1/encryption/encrypt                  ");
    writefln("    POST      /api/v1/encryption/decrypt                  ");
    writefln("    CRUD      /api/v1/bindings                            ");
    writefln("    GET       /api/v1/audit-logs                          ");
    writefln("    GET       /api/v1/overview                            ");
    writefln("    GET       /api/v1/health                              ");
    writefln("==========================================================");

    runApplication();
  }
}
