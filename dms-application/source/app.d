/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.core.core : runApplication;
// 
// import uim.platform.dms.application.infrastructure.config;
// import uim.platform.dms.application.infrastructure.container;

import uim.platform.dms.application;

@safe:
version (unittest)
{
}
else
{
  void main()
  {
    auto config = loadConfig();
    auto container = buildContainer(config);

    auto router = new URLRouter;

    // Register all controllers
    container.healthController.registerRoutes(router);
    container.repositoryController.registerRoutes(router);
    container.folderController.registerRoutes(router);
    container.documentController.registerRoutes(router);
    container.versionController.registerRoutes(router);
    container.shareController.registerRoutes(router);
    container.permissionController.registerRoutes(router);
    container.browseController.registerRoutes(router);

    auto settings = new HTTPServerSettings;
    settings.port = config.port;
    settings.bindAddresses = [config.host];

    auto listener = listenHTTP(settings, router);

    scope (exit)
      listener.stopListening();

    runApplication();
  }
}
