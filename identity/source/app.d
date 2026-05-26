/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.identity;
import vibe.http.server;
import vibe.http.router;
import vibe.core.core : runApplication;
import std.stdio : writeln;
import std.conv : to;

void main() {
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();

    // Health endpoint
    router.get("/api/v1/health", (scope HTTPServerRequest req, scope HTTPServerResponse res) @safe {
        res.writeJsonBody(Json.emptyObject
            .set("status", "UP")
            .set("service", "uim-identity-platform-service")
            .set("version", "1.0.0"), 200);
    });

    // IAS endpoints
    container.userController.registerRoutes(router);
    container.groupController.registerRoutes(router);
    container.applicationController.registerRoutes(router);
    container.identityProviderController.registerRoutes(router);

    // IPS endpoints
    container.provisioningJobController.registerRoutes(router);

    // Web UI
    container.identityWebController.registerRoutes(router);

    auto settings = new HTTPServerSettings();
    settings.bindAddresses = [config.host];
    settings.port = config.port;

    writeln("╔══════════════════════════════════════════════════════════════════╗");
    writeln("║          UIM Identity Platform Service  v1.0.0                  ║");
    writeln("╠══════════════════════════════════════════════════════════════════╣");
    writeln("║  SAP Cloud Identity Services equivalent (IAS + IPS)             ║");
    writeln("╠══════════════════════════════════════════════════════════════════╣");
    writeln("║  Health          GET  /api/v1/health                            ║");
    writeln("╠═══════════════════ IAS ═══════════════════════════════════════════╣");
    writeln("║  Users           GET  /api/v1/ias/users                         ║");
    writeln("║                  POST /api/v1/ias/users                         ║");
    writeln("║                  GET  /api/v1/ias/users/:id                     ║");
    writeln("║                  PUT  /api/v1/ias/users/:id                     ║");
    writeln("║                  DEL  /api/v1/ias/users/:id                     ║");
    writeln("║  Groups          GET  /api/v1/ias/groups                        ║");
    writeln("║                  POST /api/v1/ias/groups                        ║");
    writeln("║                  GET  /api/v1/ias/groups/:id                    ║");
    writeln("║                  PUT  /api/v1/ias/groups/:id                    ║");
    writeln("║                  DEL  /api/v1/ias/groups/:id                    ║");
    writeln("║  Applications    GET  /api/v1/ias/applications                  ║");
    writeln("║                  POST /api/v1/ias/applications                  ║");
    writeln("║                  GET  /api/v1/ias/applications/:id              ║");
    writeln("║                  PUT  /api/v1/ias/applications/:id              ║");
    writeln("║                  DEL  /api/v1/ias/applications/:id              ║");
    writeln("║  Identity Provs  GET  /api/v1/ias/identity-providers            ║");
    writeln("║                  POST /api/v1/ias/identity-providers            ║");
    writeln("║                  GET  /api/v1/ias/identity-providers/:id        ║");
    writeln("║                  PUT  /api/v1/ias/identity-providers/:id        ║");
    writeln("║                  DEL  /api/v1/ias/identity-providers/:id        ║");
    writeln("╠═══════════════════ IPS ═══════════════════════════════════════════╣");
    writeln("║  Prov Jobs       GET  /api/v1/ips/provisioning-jobs             ║");
    writeln("║                  POST /api/v1/ips/provisioning-jobs             ║");
    writeln("║                  GET  /api/v1/ips/provisioning-jobs/:id         ║");
    writeln("║                  DEL  /api/v1/ips/provisioning-jobs/:id         ║");
    writeln("║                  POST /api/v1/ips/provisioning-jobs/:id/start   ║");
    writeln("║                  POST /api/v1/ips/provisioning-jobs/:id/cancel  ║");
    writeln("╠═══════════════════ WEB ═══════════════════════════════════════════╣");
    writeln("║  Web             GET  /web/identity/users                       ║");
    writeln("║                  GET  /web/identity/groups                      ║");
    writeln("║                  GET  /web/identity/applications                ║");
    writeln("╠══════════════════════════════════════════════════════════════════╣");
    writeln("║  Backend: ", config.backend.to!string, "                                               ║");
    writeln("║  Listening on: http://", config.host, ":", config.port.to!string, "                     ║");
    writeln("╚══════════════════════════════════════════════════════════════════╝");

    listenHTTP(settings, router);
    runApplication();
}
