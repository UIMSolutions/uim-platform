/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.responsibility;
import vibe.core.core : runApplication;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerSettings, listenHTTP;

void main() {
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter();
    container.healthController.registerRoutes(router);
    container.ruleController.registerRoutes(router);
    container.categoryController.registerRoutes(router);
    container.teamTypeController.registerRoutes(router);
    container.teamController.registerRoutes(router);
    container.memberController.registerRoutes(router);
    container.functionController.registerRoutes(router);
    container.contextController.registerRoutes(router);
    container.definitionController.registerRoutes(router);
    container.determinationController.registerRoutes(router);
    container.logController.registerRoutes(router);

    auto settings = new HTTPServerSettings();
    settings.bindAddresses = [config.host];
    settings.port = config.port;

    import std.stdio : writeln;
    writeln("======================================================");
    writeln("  UIM Responsibility Management Platform Service");
    writeln("  Listening on http://", config.host, ":", config.port);
    writeln("  API base: /api/v1/responsibility/");
    writeln("======================================================");

    listenHTTP(settings, router);
    runApplication();
}
