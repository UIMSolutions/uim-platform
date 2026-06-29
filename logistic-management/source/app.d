/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;
import uim.platform.logistic_management;
import vibe.vibe;

void main() {
  // ─── Load configuration ────────────────────────────────────────────────────
  auto cfg = loadConfig();

  // ─── Build dependency container ────────────────────────────────────────────
  auto container = buildContainer(cfg);

  // ─── Register routes ───────────────────────────────────────────────────────
  auto router = new URLRouter();
  container.carrierCtrl.registerRoutes(router);
  container.freightOrderCtrl.registerRoutes(router);
  container.shipmentCtrl.registerRoutes(router);
  container.deliveryCtrl.registerRoutes(router);
  container.warehouseOrderCtrl.registerRoutes(router);
  container.warehouseTaskCtrl.registerRoutes(router);
  container.healthCtrl.registerRoutes(router);

  // ─── HTTP server settings ──────────────────────────────────────────────────
  auto settings = new HTTPServerSettings();
  settings.bindAddresses = [cfg.host];
  settings.port = cfg.port;

  listenHTTP(settings, router);

  // ─── ASCII banner ──────────────────────────────────────────────────────────
  import std.stdio : writefln;
  writefln(
    "  _                _     _   _          __  __             \n" ~
    " | |    ___   __ _(_)___| |_(_) ___ ___|  \\/  |__ _ _ __  \n" ~
    " | |   / _ \\ / _` | / __| __| |/ __/ __| |\\/| / _` | '_ \\ \n" ~
    " | |__| (_) | (_| | \\__ \\ |_| | (__\\__ \\ |  | | (_| | | | |\n" ~
    " |_____\\___/ \\__, |_|___/\\__|_|\\___|___/_|  |_|\\__, |_| |_|\n" ~
    "             |___/                              |___/        \n"
  );
  writefln("[logistic-management] Listening on %s:%d", cfg.host, cfg.port);
  writefln("[logistic-management] Endpoints: /api/v1/carriers | /api/v1/freight-orders | " ~
           "/api/v1/shipments | /api/v1/deliveries | /api/v1/warehouse-orders | " ~
           "/api/v1/warehouse-tasks | /api/v1/health");

  runApplication();
}
