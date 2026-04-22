/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.keystore.infrastructure.config;
import uim.platform.keystore.infrastructure.container;

@safe:

version (unittest) {
} else {
  void main() {
    auto config    = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Register all controller routes (driving adapters)
    container.keystoreController.registerRoutes(router);
    container.keyEntryController.registerRoutes(router);
    container.keyPasswordController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    auto settings          = new HTTPServerSettings();
    settings.port          = config.port;
    settings.bindAddresses = [config.host];

    listenHTTP(settings, router);

    writefln("==========================================================");
    writefln("  Keystore Service (SAP BTP-compatible)");
    writefln("  Listening on %s:%d", config.host, config.port);
    writefln("                                                          ");
    writefln("  Endpoints:                                              ");
    writefln("    POST      /api/v1/keystores          (upload-keystore)");
    writefln("    GET       /api/v1/keystores          (list-keystores) ");
    writefln("    GET       /api/v1/keystores/{id}     (download)       ");
    writefln("    PUT       /api/v1/keystores/{id}     (update)         ");
    writefln("    DELETE    /api/v1/keystores/{id}     (delete-keystore)");
    writefln("    GET       /api/v1/keystores/resolve  (name + scope)   ");
    writefln("    POST      /api/v1/keystores/*/entries                 ");
    writefln("    GET       /api/v1/keystores/*/entries                 ");
    writefln("    GET       /api/v1/keystores/*/entries/*               ");
    writefln("    DELETE    /api/v1/keystores/*/entries/*               ");
    writefln("    PUT       /api/v1/passwords/{alias}  (set password)   ");
    writefln("    GET       /api/v1/passwords/{alias}  (get password)   ");
    writefln("    DELETE    /api/v1/passwords/{alias}  (delete password)");
    writefln("    GET       /api/v1/passwords           (list passwords) ");
    writefln("    GET       /api/v1/health                               ");
    writefln("==========================================================");

    runApplication();
  }
}
