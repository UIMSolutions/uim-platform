/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.customer_identity;

@safe:

version (unittest) {
}
else {
  void main() {
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Register all controllers
    container.customerController.registerRoutes(router);
    container.customerSessionController.registerRoutes(router);
    container.socialIdentityController.registerRoutes(router);
    container.consentRecordController.registerRoutes(router);
    container.auditLogController.registerRoutes(router);
    container.identityProviderController.registerRoutes(router);
    container.screenSetController.registerRoutes(router);
    container.sitePolicyController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    writeln("====================================================");
    writeln("  Customer Identity Service (CIAM B2C)");
    writeln("====================================================");
    writeln("  Endpoints:");
    writeln("    GET    /api/v1/customer-identity/customers");
    writeln("    POST   /api/v1/customer-identity/customers");
    writeln("    GET    /api/v1/customer-identity/customers/:id");
    writeln("    PUT    /api/v1/customer-identity/customers/:id");
    writeln("    DELETE /api/v1/customer-identity/customers/:id");
    writeln("    GET    /api/v1/customer-identity/sessions");
    writeln("    POST   /api/v1/customer-identity/sessions");
    writeln("    GET    /api/v1/customer-identity/sessions/:id");
    writeln("    DELETE /api/v1/customer-identity/sessions/:id");
    writeln("    GET    /api/v1/customer-identity/social-identities");
    writeln("    POST   /api/v1/customer-identity/social-identities");
    writeln("    GET    /api/v1/customer-identity/social-identities/:id");
    writeln("    PUT    /api/v1/customer-identity/social-identities/:id");
    writeln("    DELETE /api/v1/customer-identity/social-identities/:id");
    writeln("    GET    /api/v1/customer-identity/consents");
    writeln("    POST   /api/v1/customer-identity/consents");
    writeln("    GET    /api/v1/customer-identity/consents/:id");
    writeln("    PUT    /api/v1/customer-identity/consents/:id");
    writeln("    DELETE /api/v1/customer-identity/consents/:id");
    writeln("    GET    /api/v1/customer-identity/audit-logs");
    writeln("    POST   /api/v1/customer-identity/audit-logs");
    writeln("    GET    /api/v1/customer-identity/audit-logs/:id");
    writeln("    DELETE /api/v1/customer-identity/audit-logs/:id");
    writeln("    GET    /api/v1/customer-identity/identity-providers");
    writeln("    POST   /api/v1/customer-identity/identity-providers");
    writeln("    GET    /api/v1/customer-identity/identity-providers/:id");
    writeln("    PUT    /api/v1/customer-identity/identity-providers/:id");
    writeln("    DELETE /api/v1/customer-identity/identity-providers/:id");
    writeln("    GET    /api/v1/customer-identity/screen-sets");
    writeln("    POST   /api/v1/customer-identity/screen-sets");
    writeln("    GET    /api/v1/customer-identity/screen-sets/:id");
    writeln("    PUT    /api/v1/customer-identity/screen-sets/:id");
    writeln("    DELETE /api/v1/customer-identity/screen-sets/:id");
    writeln("    GET    /api/v1/customer-identity/policies");
    writeln("    POST   /api/v1/customer-identity/policies");
    writeln("    GET    /api/v1/customer-identity/policies/:id");
    writeln("    PUT    /api/v1/customer-identity/policies/:id");
    writeln("    DELETE /api/v1/customer-identity/policies/:id");
    writeln("    GET    /health");
    writeln("====================================================");
    writefln("  Listening on %s:%d", config.host, config.port);
    writeln("====================================================");

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];
    auto listener = listenHTTP(settings, router);
    scope (exit) listener.stopListening();
    runApplication();
  }
}
