/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.feature_flags;
import vibe.d;

void main() {
    auto cfg    = loadConfig();
    auto router = new URLRouter();

    // Health endpoint
    router.get("/api/v1/health", (req, res) @safe {
        auto j = Json.emptyObject;
        j["status"]  = "UP";
        j["service"] = cfg.serviceName;
        j["storage"] = cfg.storageBackend;
        res.writeJsonBody(j, cast(int) HTTPStatus.ok);
    });

    // Wire DI container
    auto c = buildContainer(cfg);

    // HTTP API routes
    c.featureFlagController.registerRoutes(router);
    c.evaluationController.registerRoutes(router);
    c.serviceInstanceController.registerRoutes(router);

    // Web view routes
    c.featureFlagWebView.registerRoutes(router);

    auto settings             = new HTTPServerSettings();
    settings.bindAddresses    = [cfg.host];
    settings.port             = cfg.port;

    import std.stdio : writeln;
    writeln("╔══════════════════════════════════════════════════════════════╗");
    writeln("║      UIM Platform - Feature Flags Service                    ║");
    writeln("╠══════════════════════════════════════════════════════════════╣");
    writeln("║  SAP BTP-compatible Feature Flags management & evaluation    ║");
    writeln("╠══════════════════════════════════════════════════════════════╣");
    import std.stdio : writefln;
    writefln("║  Listening : http://%s:%d", cfg.host, cfg.port);
    writefln("║  Storage   : %s", cfg.storageBackend);
    writeln("╠══════════════════════════════════════════════════════════════╣");
    writeln("║  REST API Endpoints:                                         ║");
    writeln("║  GET    /api/v1/health                                       ║");
    writeln("║  --- Service Instances ---                                    ║");
    writeln("║  GET    /api/v1/feature-flags/instances                      ║");
    writeln("║  POST   /api/v1/feature-flags/instances                      ║");
    writeln("║  GET    /api/v1/feature-flags/instances/:id                  ║");
    writeln("║  PUT    /api/v1/feature-flags/instances/:id                  ║");
    writeln("║  DELETE /api/v1/feature-flags/instances/:id                  ║");
    writeln("║  --- Feature Flags ---                                        ║");
    writeln("║  GET    /api/v1/feature-flags/flags                          ║");
    writeln("║  POST   /api/v1/feature-flags/flags                          ║");
    writeln("║  GET    /api/v1/feature-flags/flags/:id                      ║");
    writeln("║  PUT    /api/v1/feature-flags/flags/:id                      ║");
    writeln("║  PATCH  /api/v1/feature-flags/flags/:id  (state transition)  ║");
    writeln("║  DELETE /api/v1/feature-flags/flags/:id                      ║");
    writeln("║  --- Evaluation ---                                           ║");
    writeln("║  GET    /api/v1/feature-flags/evaluate/:flagName             ║");
    writeln("║  GET    /api/v1/feature-flags/evaluate  (bulk)               ║");
    writeln("╚══════════════════════════════════════════════════════════════╝");

    listenHTTP(settings, router);
    runApplication();
}
