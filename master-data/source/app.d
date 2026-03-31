module app;

import vibe.http.server;
import vibe.http.router;
import vibe.core.core : runApplication;

import infrastructure.config;
import infrastructure.container;

import std.stdio : writefln;

void main()
{
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Register all controller routes (driving adapters)
    container.masterDataController.registerRoutes(router);
    container.dataModelController.registerRoutes(router);
    container.distributionController.registerRoutes(router);
    container.keyMappingController.registerRoutes(router);
    container.clientController.registerRoutes(router);
    container.replicationController.registerRoutes(router);
    container.filterRuleController.registerRoutes(router);
    container.changeLogController.registerRoutes(router);
    container.healthController.registerRoutes(router);

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];

    auto listener = listenHTTP(settings, router);

    writefln("==========================================================");
    writefln("  Master Data Integration Service");
    writefln("  Listening on %s:%d", config.host, config.port);
    writefln("                                                          ");
    writefln("  Endpoints:                                              ");
    writefln("    CRUD      /api/v1/master-data                         ");
    writefln("    GET       /api/v1/master-data/lookup?globalId=...     ");
    writefln("    CRUD      /api/v1/data-models                         ");
    writefln("    CRUD      /api/v1/distribution-models                 ");
    writefln("    POST      /api/v1/distribution-models/activate/{id}   ");
    writefln("    POST      /api/v1/distribution-models/deactivate/{id} ");
    writefln("    CRUD      /api/v1/key-mappings                        ");
    writefln("    GET       /api/v1/key-mappings/lookup?...             ");
    writefln("    CRUD      /api/v1/clients                             ");
    writefln("    POST      /api/v1/clients/connect/{id}                ");
    writefln("    POST      /api/v1/clients/disconnect/{id}             ");
    writefln("    CRUD      /api/v1/replication-jobs                    ");
    writefln("    POST      /api/v1/replication-jobs/start/{id}         ");
    writefln("    POST      /api/v1/replication-jobs/pause/{id}         ");
    writefln("    POST      /api/v1/replication-jobs/cancel/{id}        ");
    writefln("    CRUD      /api/v1/filter-rules                        ");
    writefln("    GET       /api/v1/change-log                          ");
    writefln("    GET       /api/v1/change-log?deltaToken=...           ");
    writefln("    GET       /api/v1/health                              ");
    writefln("==========================================================");

    scope (exit)
        listener.stopListening();
    runApplication();
}
