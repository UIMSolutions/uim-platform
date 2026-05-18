/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.alert_notification;
import vibe.d;

void main() {
    auto cfg    = loadConfig();
    auto router = new URLRouter();

    // Health endpoint
    router.get("/api/v1/health", (req, res) @safe {
        auto j = Json.emptyObject;
        j["status"]  = "UP";
        j["service"] = cfg.serviceName;
        res.writeJsonBody(j, cast(int)HTTPStatus.ok);
    });

    // Wire DI container and register all routes
    auto c = buildContainer(cfg);
    c.conditionController.registerRoutes(router);
    c.actionController.registerRoutes(router);
    c.subscriptionController.registerRoutes(router);
    c.alertEventController.registerRoutes(router);
    c.matchedEventController.registerRoutes(router);
    c.undeliveredEventController.registerRoutes(router);

    auto settings      = new HTTPServerSettings();
    settings.bindAddresses = [cfg.host];
    settings.port      = cfg.port;

    import std.stdio : writeln;
    writeln("------------------------------------------------------------");
    writeln(" UIM Platform - Alert Notification Service");
    writeln(" Listening on http://", cfg.host, ":", cfg.port);
    writeln("------------------------------------------------------------");
    writeln(" API Endpoints:");
    writeln("   POST   /api/v1/alert-notification/events");
    writeln("   GET    /api/v1/alert-notification/matched-events");
    writeln("   GET    /api/v1/alert-notification/matched-events/:id");
    writeln("   GET    /api/v1/alert-notification/undelivered-events");
    writeln("   GET    /api/v1/alert-notification/undelivered-events/:id");
    writeln("   POST   /api/v1/alert-notification/conditions");
    writeln("   GET    /api/v1/alert-notification/conditions");
    writeln("   GET    /api/v1/alert-notification/conditions/:id");
    writeln("   PUT    /api/v1/alert-notification/conditions/:id");
    writeln("   DELETE /api/v1/alert-notification/conditions/:id");
    writeln("   POST   /api/v1/alert-notification/actions");
    writeln("   GET    /api/v1/alert-notification/actions");
    writeln("   GET    /api/v1/alert-notification/actions/:id");
    writeln("   PUT    /api/v1/alert-notification/actions/:id");
    writeln("   DELETE /api/v1/alert-notification/actions/:id");
    writeln("   POST   /api/v1/alert-notification/subscriptions");
    writeln("   GET    /api/v1/alert-notification/subscriptions");
    writeln("   GET    /api/v1/alert-notification/subscriptions/:id");
    writeln("   PUT    /api/v1/alert-notification/subscriptions/:id");
    writeln("   DELETE /api/v1/alert-notification/subscriptions/:id");
    writeln("   GET    /api/v1/health");
    writeln("------------------------------------------------------------");

    listenHTTP(settings, router);
    runApplication();
}
