/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
import uim.platform.appevents;
import vibe.http.server;
import vibe.http.router;
import vibe.core.core;

void main() @safe {
    auto config = loadConfig();
    auto c = buildContainer(config);

    auto router = new URLRouter;
    c.subscriptionCtrl.registerRoutes(router);
    c.topicCtrl.registerRoutes(router);
    c.channelCtrl.registerRoutes(router);
    c.messageCtrl.registerRoutes(router);
    c.filterCtrl.registerRoutes(router);
    c.deadLetterCtrl.registerRoutes(router);
    c.formationCtrl.registerRoutes(router);
    c.systemCtrl.registerRoutes(router);
    c.healthCtrl.registerRoutes(router);

    auto settings = new HTTPServerSettings;
    settings.bindAddresses = [config.host];
    settings.port          = cast(ushort) config.port;
    listenHTTP(settings, router);
    runApplication();
}
