/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.snowflake;
import vibe.http.server;
import vibe.http.router;
import vibe.core.core : runApplication;
import std.stdio : writeln;

void main() {
  auto cfg = loadConfig();
  auto c   = buildContainer(cfg);

  writeln("=============================================================================");
  writeln("  SAP Snowflake  — UIM Platform Service");
  writeln("=============================================================================");
  writeln("  Host    : ", cfg.host);
  writeln("  Port    : ", cfg.port);
  writeln("  Service : ", cfg.serviceName);
  writeln("-----------------------------------------------------------------------------");
  writeln("  Endpoints:");
  writeln("    GET    /api/v1/health");
  writeln("    CRUD   /api/v1/snowflake/accounts         (Snowflake Accounts)");
  writeln("    POST   /api/v1/snowflake/accounts/*/activate");
  writeln("    CRUD   /api/v1/snowflake/connectors       (Zero-Copy Connectors)");
  writeln("    POST   /api/v1/snowflake/connectors/*/enroll");
  writeln("    CRUD   /api/v1/snowflake/warehouses       (Snowflake Warehouses)");
  writeln("    CRUD   /api/v1/snowflake/databases        (Snowflake Databases)");
  writeln("    CRUD   /api/v1/snowflake/shares           (Data Product Shares)");
  writeln("    POST   /api/v1/snowflake/shares/*/sync");
  writeln("    CRUD   /api/v1/snowflake/roles            (Snowflake Roles)");
  writeln("    CRUD   /api/v1/snowflake/users            (Tenant Users)");
  writeln("    GET    /api/v1/snowflake/requests         (Provisioning Requests)");
  writeln("    GET    /api/v1/snowflake/requests/*");
  writeln("    POST   /api/v1/snowflake/requests");
  writeln("    DELETE /api/v1/snowflake/requests/*");
  writeln("    POST   /api/v1/snowflake/requests/*/process");
  writeln("    POST   /api/v1/snowflake/requests/*/complete");
  writeln("    POST   /api/v1/snowflake/requests/*/fail");
  writeln("=============================================================================");

  auto router = new URLRouter();
  c.healthCtrl.registerRoutes(router);
  c.accountCtrl.registerRoutes(router);
  c.connectorCtrl.registerRoutes(router);
  c.warehouseCtrl.registerRoutes(router);
  c.databaseCtrl.registerRoutes(router);
  c.shareCtrl.registerRoutes(router);
  c.roleCtrl.registerRoutes(router);
  c.tenantUserCtrl.registerRoutes(router);
  c.provisioningCtrl.registerRoutes(router);

  auto settings = new HTTPServerSettings();
  settings.bindAddresses = [cfg.host];
  settings.port = cast(ushort) cfg.port;

  listenHTTP(settings, router);
  runApplication();
}
