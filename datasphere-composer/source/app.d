/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.datasphere_composer;
import vibe.http.server;
import vibe.http.router;
import vibe.core.core : runApplication;
import std.stdio : writeln;

void main() {
  auto cfg = loadConfig();
  auto c   = buildContainer(cfg);

  writeln("=============================================================================");
  writeln("  Datasphere Data Composer  — UIM Platform Service");
  writeln("=============================================================================");
  writeln("  Host    : ", cfg.host);
  writeln("  Port    : ", cfg.port);
  writeln("  Service : ", cfg.serviceName);
  writeln("-----------------------------------------------------------------------------");
  writeln("  Endpoints:");
  writeln("    GET    /api/v1/health");
  writeln("    CRUD   /api/v1/composer/providers         (Data Providers)");
  writeln("    CRUD   /api/v1/composer/products          (Data Products)");
  writeln("    GET    /api/v1/composer/providers/*/products");
  writeln("    CRUD   /api/v1/composer/rules             (Unification Rules)");
  writeln("    POST   /api/v1/composer/rules/reorder");
  writeln("    CRUD   /api/v1/composer/configs           (Data Source Configs)");
  writeln("    POST   /api/v1/composer/configs/*/identifierMappings");
  writeln("    CRUD   /api/v1/composer/mappings          (Attribute Mappings)");
  writeln("    GET    /api/v1/composer/profiles          (Customer Profiles)");
  writeln("    GET    /api/v1/composer/profiles/*");
  writeln("    POST   /api/v1/composer/profiles/search");
  writeln("    POST   /api/v1/composer/runs              (Composition Runs - start)");
  writeln("    GET    /api/v1/composer/runs");
  writeln("    GET    /api/v1/composer/runs/*");
  writeln("    DELETE /api/v1/composer/runs/*");
  writeln("    POST   /api/v1/composer/runs/*/action");
  writeln("    CRUD   /api/v1/composer/users             (Tenant Users)");
  writeln("=============================================================================");

  auto router = new URLRouter();
  c.healthCtrl.registerRoutes(router);
  c.dataProviderCtrl.registerRoutes(router);
  c.dataProductCtrl.registerRoutes(router);
  c.unificationRuleCtrl.registerRoutes(router);
  c.dataSourceConfigCtrl.registerRoutes(router);
  c.attributeMappingCtrl.registerRoutes(router);
  c.customerProfileCtrl.registerRoutes(router);
  c.compositionRunCtrl.registerRoutes(router);
  c.tenantUserCtrl.registerRoutes(router);

  auto settings = new HTTPServerSettings();
  settings.bindAddresses = [cfg.host];
  settings.port = cast(ushort) cfg.port;

  listenHTTP(settings, router);
  runApplication();
}
