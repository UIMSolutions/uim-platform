module app;

import vibe.http.server;
import vibe.http.router;
import vibe.core.core : runApplication;

import uim.platform.cloud_foundry.infrastructure.config;
import uim.platform.cloud_foundry.infrastructure.container;

import std.stdio : writefln;
@safe:

version (unittest) {
} else {
void main() {
  auto config = loadConfig();
  auto container = buildContainer(config);

  auto router = new URLRouter();

  // Register all controller routes (driving adapters)
  container.orgController.registerRoutes(router);
  container.spaceController.registerRoutes(router);
  container.appController.registerRoutes(router);
  container.serviceController.registerRoutes(router);
  container.routeController.registerRoutes(router);
  container.buildpackController.registerRoutes(router);
  container.monitoringController.registerRoutes(router);
  container.healthController.registerRoutes(router);

  auto settings = new HTTPServerSettings();
  settings.port = config.port;
  settings.bindAddresses = [config.host];

  auto listener = listenHTTP(settings, router);

  writefln("==========================================================");
  writefln("  Cloud Foundry Runtime Service");
  writefln("  Listening on %s:%d", config.host, config.port);
  writefln("                                                          ");
  writefln("  Endpoints:                                              ");
  writefln("    CRUD      /api/v1/orgs                                ");
  writefln("              /api/v1/orgs/suspend|activate/*              ");
  writefln("    CRUD      /api/v1/spaces                              ");
  writefln("    CRUD      /api/v1/apps                                ");
  writefln("              /api/v1/apps/start|stop|restart|scale/*      ");
  writefln("              /api/v1/apps/env/*                           ");
  writefln("    CRUD      /api/v1/service-instances                   ");
  writefln("    CR D      /api/v1/service-bindings                    ");
  writefln("    CR D      /api/v1/routes                              ");
  writefln("              /api/v1/routes/map|unmap/*                   ");
  writefln("    CR D      /api/v1/domains                             ");
  writefln("    CRUD      /api/v1/buildpacks                          ");
  writefln("    GET       /api/v1/monitoring/apps                     ");
  writefln("    GET       /api/v1/monitoring/apps/*                   ");
  writefln("    GET       /api/v1/monitoring/spaces/*                 ");
  writefln("    GET       /api/v1/health                              ");
  writefln("==========================================================");

  runApplication();
}
