module app;

// import vibe.http.server;
import vibe.http.router;
import vibe.core.core : runApplication;

import uim.platform.identity.provisioning.infrastructure.config;
import uim.platform.identity.provisioning.infrastructure.container;
@safe:

version (unittest) {
} else {
void main() {
  auto config = loadConfig();
  auto container = buildContainer(config);

  auto router = new URLRouter;

  // Register all controllers
  container.healthController.registerRoutes(router);
  container.sourceSystemController.registerRoutes(router);
  container.targetSystemController.registerRoutes(router);
  container.proxySystemController.registerRoutes(router);
  container.transformationController.registerRoutes(router);
  container.provisioningJobController.registerRoutes(router);
  container.monitoringController.registerRoutes(router);

  auto settings = new HTTPServerSettings;
  settings.port = config.port;
  settings.bindAddresses = [config.host];

  auto listener = listenHTTP(settings, router);

  scope (exit)
    listener.stopListening();

  runApplication();
}
