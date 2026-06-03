module app;

import std.algorithm.searching : canFind;
import std.getopt : getopt;
import std.process : environment;
import std.stdio : writeln, writefln;
import uim.platform.analytics;

version (unittest) {
}
else {
  void main(string[] args) {
    auto config = loadConfig();
    auto container = buildContainer(config);

    string tenantId = "default";
    bool cliMode = false;
    getopt(args, "tenant", &tenantId, "cli", &cliMode);

    if (environment.get("ANALYTICS_RUN_MODE", "") == "cli") {
      cliMode = true;
    }

    if (cliMode || args.canFind("cli")) {
      writeln(container.cliController.renderOverview(tenantId));
      return;
    }

    auto router = new URLRouter();

    container.assetsController.registerRoutes(router);
    container.healthController.registerRoutes(router);
    container.webController.registerRoutes(router);
    container.guiController.registerRoutes(router);

    writeln("====================================================");
    writeln("  Analytics Service");
    writeln("====================================================");
    writeln("  Endpoints:");
    writeln("    GET    /api/v1/health");
    writeln("    GET    /api/v1/analytics/assets");
    writeln("    POST   /api/v1/analytics/assets");
    writeln("    GET    /api/v1/analytics/assets/:id");
    writeln("    PUT    /api/v1/analytics/assets/:id");
    writeln("    DELETE /api/v1/analytics/assets/:id");
    writeln("    POST   /api/v1/analytics/assets/:id/publish");
    writeln("    GET    /web");
    writeln("    GET    /gui");
    writeln("====================================================");
    writefln("  Listening on %s:%d", config.host, config.port);
    writeln("====================================================");

    auto settings = new HTTPServerSettings();
    settings.port = config.port;
    settings.bindAddresses = [config.host];

    auto listener = listenHTTP(settings, router);
    scope (exit) listener.stopListening();

    runApplication();
  }
}
