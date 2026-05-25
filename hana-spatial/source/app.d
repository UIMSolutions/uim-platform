/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import vibe.d;
import uim.platform.hana_spatial;

void main() {
  auto config = loadConfig();

  writeln("============================================================");
  writeln("  UIM HANA Spatial Platform Service");
  writeln("  Version : 2026.0.1");
  writeln("  Port    : ", config.port);
  writeln("  Host    : ", config.host);
  writeln("============================================================");
  writeln("  Endpoints:");
  writeln("    GET    /api/v1/health");
  writeln("    POST   /api/v1/spatial/geocode        (forward geocoding)");
  writeln("    POST   /api/v1/spatial/reverseGeocode (reverse geocoding)");
  writeln("    GET    /api/v1/spatial/geocode");
  writeln("    GET    /api/v1/spatial/geocode/:id");
  writeln("    DELETE /api/v1/spatial/geocode/:id");
  writeln("    CRUD   /api/v1/spatial/routes");
  writeln("    CRUD   /api/v1/spatial/poi");
  writeln("    CRUD   /api/v1/spatial/isolines       (isoline calculation)");
  writeln("    CRUD   /api/v1/spatial/geofences");
  writeln("    POST   /api/v1/spatial/geofences/check");
  writeln("    CRUD   /api/v1/spatial/layers");
  writeln("    CRUD   /api/v1/spatial/features");
  writeln("    CRUD   /api/v1/spatial/providers");
  writeln("    CRUD   /api/v1/spatial/geocodingJobs  (batch geocoding)");
  writeln("    POST   /api/v1/spatial/geocodingJobs/:id/action");
  writeln("============================================================");

  auto container = buildContainer(config);
  auto router = new URLRouter();

  container.healthController.registerRoutes(router);
  container.geocodingController.registerRoutes(router);
  container.routingController.registerRoutes(router);
  container.poiController.registerRoutes(router);
  container.isolineController.registerRoutes(router);
  container.geofenceController.registerRoutes(router);
  container.spatialLayerController.registerRoutes(router);
  container.spatialFeatureController.registerRoutes(router);
  container.providerController.registerRoutes(router);
  container.geocodingJobController.registerRoutes(router);

  auto settings = new HTTPServerSettings();
  settings.port = cast(ushort) config.port;
  settings.bindAddresses = [config.host];

  listenHTTP(settings, router);
  writeln("  Service started. Listening on ", config.host, ":", config.port);
  writeln("============================================================");

  runApplication();
}
