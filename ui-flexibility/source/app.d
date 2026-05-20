/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import std.stdio : writeln;
import vibe.vibe;
import uim.platform.ui_flexibility;

void main() {
  writeln(q"[
  ╔══════════════════════════════════════════════════════════════╗
  ║     UIM UI Flexibility Platform Service  v2.0.0              ║
  ║     SAP BTP-compatible Flex Change/Variant Management        ║
  ╠══════════════════════════════════════════════════════════════╣
  ║  Key User API  (adaptations, variants, versions, drafts)     ║
  ║    POST/GET/PUT/DELETE  /keyuser/v2/changes                  ║
  ║    POST/GET/PUT/DELETE  /keyuser/v2/variants                 ║
  ║    POST/GET/PUT/DELETE  /keyuser/v2/versions                 ║
  ║    POST   /keyuser/v2/versions/*/activate                    ║
  ║    POST/GET/PUT/DELETE  /keyuser/v2/drafts                   ║
  ║                                                              ║
  ║  User API  (personalizations)                                ║
  ║    POST/GET/PUT/DELETE  /user/v2/personalizations            ║
  ║                                                              ║
  ║  Admin API  (application registry)                           ║
  ║    POST/GET/PUT/DELETE  /api/v2/applications                 ║
  ║                                                              ║
  ║  Observability                                               ║
  ║    GET  /api/v1/health                                       ║
  ╚══════════════════════════════════════════════════════════════╝
  ]");

  auto config = loadConfig();

  writeln("Storage backend : ", config.storage);
  writeln("Listening on    : ", config.host, ":", config.port);
  writeln();

  auto container = buildContainer(config);

  auto router = new URLRouter;

  container.healthController.registerRoutes(router);
  container.changeController.registerRoutes(router);
  container.variantController.registerRoutes(router);
  container.versionController.registerRoutes(router);
  container.draftController.registerRoutes(router);
  container.personalizationController.registerRoutes(router);
  container.applicationController.registerRoutes(router);

  auto settings = new HTTPServerSettings;
  settings.port    = config.port;
  settings.bindAddresses = [config.host];

  listenHTTP(settings, router);
  runApplication();
}
