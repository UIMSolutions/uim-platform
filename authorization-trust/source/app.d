/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.authorization_trust;

// mixin(ShowModule!());

@safe:

version (unittest) {
} else {
  void main() {
    auto config    = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Register all controller routes (driving adapters)
    container.oauthClientController.registerRoutes(router);
    container.scopeController.registerRoutes(router);
    container.roleController.registerRoutes(router);
    container.roleCollectionController.registerRoutes(router);
    container.userAssignmentController.registerRoutes(router);
    container.identityProviderController.registerRoutes(router);
    container.tokenController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    auto settings          = new HTTPServerSettings();
    settings.port          = config.port;
    settings.bindAddresses = [config.host];

    listenHTTP(settings, router);

    writefln("=================================================================");
    writefln("  Authorization and Trust Management Service (SAP BTP-compatible)");
    writefln("  Listening on %s:%d", config.host, config.port);
    writefln("                                                                 ");
    writefln("  Endpoints:                                                     ");
    writefln("    POST/GET/PUT/DELETE  /api/v1/oauth/clients                  ");
    writefln("    POST/GET/PUT/DELETE  /api/v1/scopes                         ");
    writefln("    POST/GET/PUT/DELETE  /api/v1/roles                          ");
    writefln("    POST/GET/PUT/DELETE  /api/v1/role-collections               ");
    writefln("    POST/GET/DELETE      /api/v1/user-assignments               ");
    writefln("    POST/GET/PUT/DELETE  /api/v1/identity-providers             ");
    writefln("    POST                 /api/v1/oauth/token                    ");
    writefln("    GET                  /api/v1/health                         ");
    writefln("=================================================================");

    runApplication();
  }
}
