module app;

import vibe.http.server;
import vibe.http.router;
import vibe.core.core : runApplication;

import infrastructure.config;
import infrastructure.container;

import std.stdio : writefln;

import uim.platform.management;

@safe:

void main() {
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Register all controller routes (driving adapters)
    container.globalAccountController.registerRoutes(router);
    container.directoryController.registerRoutes(router);
    container.subaccountController.registerRoutes(router);
    container.entitlementController.registerRoutes(router);
    container.environmentController.registerRoutes(router);
    container.subscriptionController.registerRoutes(router);
    container.servicePlanController.registerRoutes(router);
    container.labelController.registerRoutes(router);
    container.eventController.registerRoutes(router);
    container.overviewController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];

    auto listener = listenHTTP(settings, router);

    writefln("==========================================================");
    writefln("  Cloud Management Service");
    writefln("  Listening on %s:%d", config.host, config.port);
    writefln("                                                          ");
    writefln("  Endpoints:                                              ");
    writefln("    CRUD    /api/v1/accounts          (global accounts)   ");
    writefln("    POST    /api/v1/accounts/suspend/{id}                 ");
    writefln("    POST    /api/v1/accounts/reactivate/{id}              ");
    writefln("    CRUD    /api/v1/directories       (directories)       ");
    writefln("    CRUD    /api/v1/subaccounts       (subaccounts)       ");
    writefln("    POST    /api/v1/subaccounts/move/{id}                 ");
    writefln("    POST    /api/v1/subaccounts/suspend/{id}              ");
    writefln("    POST    /api/v1/subaccounts/reactivate/{id}           ");
    writefln("    CRUD    /api/v1/entitlements      (entitlements)      ");
    writefln("    POST    /api/v1/entitlements/revoke/{id}              ");
    writefln("    CRUD    /api/v1/environments      (env instances)     ");
    writefln("    POST    /api/v1/environments/deprovision/{id}         ");
    writefln("    CRUD    /api/v1/subscriptions     (SaaS subs)        ");
    writefln("    POST    /api/v1/subscriptions/unsubscribe/{id}        ");
    writefln("    CRUD    /api/v1/service-plans     (service catalog)   ");
    writefln("    CRUD    /api/v1/labels            (resource labels)   ");
    writefln("    GET     /api/v1/events            (platform events)   ");
    writefln("    GET     /api/v1/overview           (account overview) ");
    writefln("    GET     /api/v1/health            (health check)      ");
    writefln("==========================================================");

    runApplication();
}
