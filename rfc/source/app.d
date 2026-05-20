/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.rfc;

import std.algorithm : canFind;
import std.conv      : to;

void main(string[] args) @trusted {
    if (args.canFind("--cli")) {
        auto runner = RfcCliRunner();
        runner.run();
        return;
    }

    auto config = SrvConfig.load();
    auto c      = buildContainer(config);

    auto router   = new URLRouter();
    auto settings = new HTTPServerSettings();
    settings.bindAddresses = [config.host];
    settings.port          = config.port;

    c.destinationController.registerRoutes(router);
    c.functionModuleController.registerRoutes(router);
    c.callController.registerRoutes(router);
    c.queueController.registerRoutes(router);
    c.healthController.registerRoutes(router);

    import vibe.core.log : logInfo;
    logInfo("UIM RFC Interface service listening on %s:%d", config.host, config.port);
    listenHTTP(settings, router);
    runApplication();
}
