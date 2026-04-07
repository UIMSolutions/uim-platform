/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.job_scheduling.infrastructure.config;
import uim.platform.job_scheduling.infrastructure.container;

import std.stdio : writefln;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerSettings;
import vibe.http.server : listenHTTP;
import vibe.core.core : runApplication;

version (unittest) {
} ) {
    void main() {
        auto config = loadConfig();
        auto container = buildContainer(config);

        auto router = new URLRouter();

        // Register all controller routes (driving adapters)
        container.jobController.registerRoutes(router);
        container.scheduleController.registerRoutes(router);
        container.runLogController.registerRoutes(router);
        container.configurationController.registerRoutes(router);
        container.healthController.registerRoutes(router);

        auto settings = new HTTPServerSettings();
        settings.port = config.port;
        settings.bindAddresses = [config.host];

        auto listener = listenHTTP(settings, router);

        writefln("==========================================================");
        writefln("  Job Scheduling Service");
        writefln("  Listening on %s:%d", config.host, config.port);
        writefln("                                                          ");
        writefln("  Scheduler API v1 Endpoints:                             ");
        writefln("    Jobs:                                                 ");
        writefln("      POST    /api/v1/scheduler/jobs                      ");
        writefln("      GET     /api/v1/scheduler/jobs                      ");
        writefln("      GET     /api/v1/scheduler/jobs/{id}                 ");
        writefln("      PUT     /api/v1/scheduler/jobs/{id}                 ");
        writefln("      DELETE  /api/v1/scheduler/jobs/{id}                 ");
        writefln("      GET     /api/v1/scheduler/jobs/count                ");
        writefln("      GET     /api/v1/scheduler/jobs/search?q=            ");
        writefln("    Schedules:                                            ");
        writefln("      POST    /api/v1/scheduler/jobs/{id}/schedules       ");
        writefln("      GET     /api/v1/scheduler/jobs/{id}/schedules       ");
        writefln("      GET     /api/v1/scheduler/jobs/{id}/schedules/{sid} ");
        writefln("      PUT     /api/v1/scheduler/jobs/{id}/schedules/{sid} ");
        writefln("      DELETE  /api/v1/scheduler/jobs/{id}/schedules/{sid} ");
        writefln("      PUT     /api/v1/scheduler/jobs/{id}/schedules/activate");
        writefln("      GET     /api/v1/scheduler/schedules/search?q=       ");
        writefln("    Run Logs:                                             ");
        writefln("      GET     /api/v1/scheduler/jobs/{id}/runLogs         ");
        writefln("      GET     /api/v1/scheduler/jobs/{id}/schedules/{sid}/runLogs");
        writefln("      PUT     /api/v1/scheduler/jobs/{id}/runLogs/{rid}   ");
        writefln("    Configuration:                                        ");
        writefln("      GET     /api/v1/scheduler/configuration             ");
        writefln("      PUT     /api/v1/scheduler/configuration             ");
        writefln("                                                          ");
        writefln("  Health:                                                 ");
        writefln("    GET       /api/v1/health                              ");
        writefln("==========================================================");

        runApplication();
    }
}
