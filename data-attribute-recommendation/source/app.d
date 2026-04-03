module app;

import vibe.http.server;
import vibe.http.router;
import vibe.core.core : runApplication;

import uim.platform.data.attribute_recommendation.infrastructure.config;
import uim.platform.data.attribute_recommendation.infrastructure.container;

import std.stdio : writefln;
@safe:

version (unittest) {
} else {
void main() {
  auto config = loadConfig();
  auto container = buildContainer(config);

  auto router = new URLRouter();

  // Register all controller routes (driving adapters)
  container.datasetController.registerRoutes(router);
  container.dataRecordController.registerRoutes(router);
  container.modelController.registerRoutes(router);
  container.deploymentController.registerRoutes(router);
  container.inferenceController.registerRoutes(router);
  container.monitoringController.registerRoutes(router);
  container.healthController.registerRoutes(router);

  auto settings = new HTTPServerSettings();
  settings.port = config.port;
  settings.bindAddresses = [config.host];

  auto listener = listenHTTP(settings, router);

  writefln("==========================================================");
  writefln("  Data Attribute Recommendation Service");
  writefln("  Listening on %s:%d", config.host, config.port);
  writefln("                                                          ");
  writefln("  Endpoints:                                              ");
  writefln("    CRUD      /api/v1/datasets                            ");
  writefln("    POST      /api/v1/datasets/validate/{id}              ");
  writefln("    POST      /api/v1/datasets/process/{id}               ");
  writefln("    CRUD      /api/v1/data-records                        ");
  writefln("    CRUD      /api/v1/models                              ");
  writefln("    POST      /api/v1/models/train/{id}                   ");
  writefln("    CRUD      /api/v1/deployments                         ");
  writefln("    POST      /api/v1/inference                           ");
  writefln("    GET       /api/v1/inference/results/{id}              ");
  writefln("    GET       /api/v1/monitoring/jobs                     ");
  writefln("    GET       /api/v1/monitoring/deployments              ");
  writefln("    GET       /api/v1/monitoring/pipeline                 ");
  writefln("    GET       /api/v1/health                              ");
  writefln("==========================================================");

  runApplication();
}
